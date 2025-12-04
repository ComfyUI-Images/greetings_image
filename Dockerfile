FROM runpod/worker-comfyui:5.5.0-base

ENV CVT="8894b6af3f93a899ba9d2f268ddc45aa"

RUN apt-get update && apt-get install -y curl \
    build-essential cmake libopenblas-dev liblapack-dev libjpeg-dev libpng-dev pkg-config python3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN /opt/venv/bin/pip install opencv-python "insightface==0.7.3" onnxruntime

# install nodes
RUN comfy node install --exit-on-fail comfyui_ipadapter_plus@2.0.0
RUN comfy node install --exit-on-fail comfyui-base64-to-image@1.0.0

RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/loras /comfyui/models/ipadapter /comfyui/models/clip_vision

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${CVT}" \
    -o /comfyui/models/checkpoints/pornmaster_proSDXLV7.safetensors \
    "https://civitai.com/api/download/models/2043971?type=Model&format=SafeTensor&size=pruned&fp=fp16"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${CVT}" \
    -o /comfyui/models/loras/Seductive_Expression_SDXL-000040.safetensors \
    "https://civitai.com/api/download/models/2188184?type=Model&format=SafeTensor"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L -H "Authorization: Bearer ${CVT}" \
    -o /comfyui/models/loras/Seductive_Finger_Lips_Expression_SDXL-000046.safetensors \
    "https://civitai.com/api/download/models/2277333?type=Model&format=SafeTensor"

# === CLIP-VISION MODELS ===
RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/clip_vision/CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors"

# === SDXL IPADAPTER MODELS ===
RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/ipadapter/ip-adapter_sdxl_vit-h.safetensors \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl_vit-h.safetensors"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/ipadapter/ip-adapter-plus_sdxl_vit-h.safetensors \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus_sdxl_vit-h.safetensors"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/ipadapter/ip-adapter-plus-face_sdxl_vit-h.safetensors \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus-face_sdxl_vit-h.safetensors"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/ipadapter/ip-adapter_sdxl.safetensors \
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter_sdxl.safetensors"

# === FACEID PLUS V2 MODELS ===
RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/ipadapter/ip-adapter-faceid-plusv2_sd15.bin \
    "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sd15.bin"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/ipadapter/ip-adapter-faceid-plusv2_sdxl.bin \
    "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl.bin"

# === FACEID PLUS V2 LoRAs ===
RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/loras/ip-adapter-faceid-plusv2_sd15_lora.safetensors \
    "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sd15_lora.safetensors"

RUN curl --fail --retry 5 --retry-max-time 0 -C - -L \
    -o /comfyui/models/loras/ip-adapter-faceid-plusv2_sdxl_lora.safetensors \
    "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl_lora.safetensors"
