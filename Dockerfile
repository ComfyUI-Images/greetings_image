# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.0-base

ENV CVT="8894b6af3f93a899ba9d2f268ddc45aa"

RUN /opt/venv/bin/pip install opencv-python insightface
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui_ipadapter_plus@2.0.0
RUN comfy node install --exit-on-fail comfyui-base64-to-image@1.0.0

# download models into comfyui
RUN mkdir -p /comfyui/models/checkpoints /comfyui/models/loras && \
    curl -L -H "Authorization: Bearer ${CVT}" -o /comfyui/models/checkpoints/pornmaster_proSDXLV7.safetensors "https://civitai.com/api/download/models/2043971?type=Model&format=SafeTensor&size=pruned&fp=fp16" && \
    curl -L -H "Authorization: Bearer ${CVT}" -o /comfyui/models/loras/Seductive_Expression_SDXL-000040.safetensors "https://civitai.com/api/download/models/2188184?type=Model&format=SafeTensor" && \
    curl -L -H "Authorization: Bearer ${CVT}" -o /comfyui/models/loras/Seductive_Finger_Lips_Expression_SDXL-000046.safetensors "https://civitai.com/api/download/models/2277333?type=Model&format=SafeTensor" && \
    # IPAdapter FaceID Plus V2 SDXL models
    curl -L -o /comfyui/models/ipadapter/ip-adapter-faceid-plusv2_sdxl.bin "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl.bin" && \
    curl -L -o /comfyui/models/loras/ip-adapter-faceid-plusv2_sdxl_lora.safetensors "https://huggingface.co/h94/IP-Adapter-FaceID/resolve/main/ip-adapter-faceid-plusv2_sdxl_lora.safetensors" && \
    # ClipVision model for IPAdapter SDXL (rename for compatibility)
    curl -L -o /comfyui/models/clip_vision/CLIP-ViT-bigG-14-laion2B-39B-b160k.safetensors "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/image_encoder/model.safetensors"

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
