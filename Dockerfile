# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.0-base

ENV CVT="8894b6af3f93a899ba9d2f268ddc45aa"

# install custom nodes into comfyui
RUN comfy node install --exit-on-fail comfyui_ipadapter_plus@2.0.0

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# download models into comfyui
RUN echo "Token value: $CVT" && mkdir -p /comfyui/models/checkpoints /comfyui/models/loras && \
    curl -L -H "Authorization: Bearer ${CVT}" -o /comfyui/models/checkpoints/pornmaster_proSDXLV7.safetensors "https://civitai.com/api/download/models/2043971?type=Model&format=SafeTensor&size=pruned&fp=fp16" && \
    curl -L -H "Authorization: Bearer ${CVT}" -o /comfyui/models/loras/Seductive_Expression_SDXL-000040.safetensors "https://civitai.com/api/download/models/2188184?type=Model&format=SafeTensor" && \
    curl -L -H "Authorization: Bearer ${CVT}" -o /comfyui/models/loras/Seductive_Finger_Lips_Expression_SDXL-000046.safetensors "https://civitai.com/api/download/models/2277333?type=Model&format=SafeTensor"

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
