FROM runpod/worker-comfyui:5.5.0-base

# Define build arguments for tokens
ARG HUGGINGFACE_TOKEN
ARG CIVITAI_TOKEN

# Set environment variables from args (optional, but for use in RUN)
ENV HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN}
ENV CIVITAI_TOKEN=${CIVITAI_TOKEN}

# Original installations
RUN apt-get update && apt-get install -y curl git \
    ffmpeg libgl1 libglib2.0-0 rsync \
    build-essential cmake libopenblas-dev liblapack-dev libjpeg-dev libpng-dev pkg-config python3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/comfyanonymous/ComfyUI.git /tmp/comfyui-new

RUN rsync -a --delete \
    --exclude models \
    --exclude custom_nodes \
    --exclude user \
    --exclude output \
    /tmp/comfyui-new/ /comfyui/

RUN rm -rf /tmp/comfyui-new

RUN /opt/venv/bin/pip install -r /comfyui/requirements.txt

RUN /opt/venv/bin/pip install opencv-python "insightface==0.7.3" onnxruntime rembg llama-cpp-python

# Disable tracking
RUN comfy --skip-prompt tracking disable
# Install nodes (original + new ones from script)
RUN comfy node install comfyui_ipadapter_plus@2.0.0
RUN comfy node install rgthree-comfy
RUN comfy node install comfyui_essentials
RUN comfy node install comfyui_ultimatesdupscale
RUN comfy node install comfyui-kjnodes

RUN git clone https://github.com/city96/ComfyUI-GGUF /comfyui/custom_nodes/ComfyUI-GGUF

# Clone ComfyUI_Base64Images (original)
RUN git clone https://github.com/Asidert/ComfyUI_Base64Images.git /comfyui/custom_nodes/ComfyUI_Base64Images

# Create directories (original + new ones from script)
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/loras /comfyui/models/ipadapter /comfyui/models/clip_vision \
    /comfyui/models/diffusion_models /comfyui/models/text_encoders /comfyui/models/vae /comfyui/models/loras/chars

# Additional downloads
RUN set -eux; \
    TARGET_DIR="/comfyui/models/loras/chars"; \
    mkdir -p "$TARGET_DIR"; \
    for char in zwc_001 zwc_002 zwc_003 zwc_004 zwc_005 zwc_006; do \
        echo "Downloading: $char.safetensors"; \
        curl --fail --retry 5 --retry-max-time 0 -C - -L \
            -o "$TARGET_DIR/$char.safetensors" \
            "https://elvale.ru/loras/chars/$char.safetensors"; \
    done; \
    echo "Downloaded all characters"

# ORIGINAL ZIT
RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${HUGGINGFACE_TOKEN}" \
    -o /comfyui/models/diffusion_models/z_image_turbo-Q4_K_S.gguf \
    "https://huggingface.co/jayn7/Z-Image-Turbo-GGUF/resolve/main/z_image_turbo-Q4_K_S.gguf?download=true"

# PORNMASTER CHECKPOINT
RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/diffusion_models/pornmasterZImage_v02Fp8.safetensors \
    "https://civitai.com/api/download/models/2580802?type=Model&format=SafeTensor&size=pruned&fp=fp8&token=8894b6af3f93a899ba9d2f268ddc45aa"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${HUGGINGFACE_TOKEN}" \
    -o /comfyui/models/text_encoders/qwen_3_4b.safetensors \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors?download=true"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${HUGGINGFACE_TOKEN}" \
    -o /comfyui/models/vae/ae.safetensors \
    "https://huggingface.co/StableDiffusionVN/Flux/resolve/main/Vae/flux_vae.safetensors?download=true"
