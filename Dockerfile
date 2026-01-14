FROM runpod/worker-comfyui:5.5.0-base

# Define build arguments for tokens
ARG HUGGINGFACE_TOKEN
ARG CIVITAI_TOKEN

# Set environment variables from args (optional, but for use in RUN)
ENV HUGGINGFACE_TOKEN=${HUGGINGFACE_TOKEN}
ENV CIVITAI_TOKEN=${CIVITAI_TOKEN}

# Original installations
RUN apt-get update && apt-get install -y curl git \
    ffmpeg libgl1 libglib2.0-0 \
    build-essential cmake libopenblas-dev liblapack-dev libjpeg-dev libpng-dev pkg-config python3-dev && \
    rm -rf /var/lib/apt/lists/*

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
    for char in zwc_001; do \
        echo "Downloading: $char.safetensors"; \
        curl --fail --retry 5 --retry-max-time 0 -C - -L \
            -o "$TARGET_DIR/$char.safetensors" \
            "https://elvale.ru/loras/chars/$char.safetensors"; \
    done; \
    echo "Downloaded all characters"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${HUGGINGFACE_TOKEN}" \
    -o /comfyui/models/diffusion_models/z_image_turbo-Q4_K_S.gguf \
    "https://huggingface.co/jayn7/Z-Image-Turbo-GGUF/resolve/main/z_image_turbo-Q4_K_S.gguf?download=true"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${CIVITAI_TOKEN}" \
    -o /comfyui/models/loras/Mystic-XXX-ZIT-v3.safetensors \
    "https://civitai.com/api/download/models/2530056?type=Model&format=SafeTensor"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${HUGGINGFACE_TOKEN}" \
    -o /comfyui/models/text_encoders/qwen_3_4b.safetensors \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors?download=true"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${HUGGINGFACE_TOKEN}" \
    -o /comfyui/models/vae/flux_vae.safetensors \
    "https://huggingface.co/StableDiffusionVN/Flux/resolve/main/Vae/flux_vae.safetensors?download=true"
