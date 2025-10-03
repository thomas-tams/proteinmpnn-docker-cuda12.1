FROM pytorch/pytorch:2.3.1-cuda12.1-cudnn8-runtime

# Set working directory
WORKDIR /app

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    numpy \
    scipy

# Clone ProteinMPNN repository
RUN git clone https://github.com/dauparas/ProteinMPNN.git /app/ProteinMPNN

# Download vanilla model weights
RUN cd /app/ProteinMPNN/vanilla_model_weights && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/model_weights/v_48_002.pt && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/model_weights/v_48_010.pt && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/model_weights/v_48_020.pt && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/model_weights/v_48_030.pt && \
    echo "Downloaded vanilla models:" && \
    ls -lh /app/ProteinMPNN/vanilla_model_weights/*.pt

# Download soluble model weights
RUN cd /app/ProteinMPNN/soluble_model_weights && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/soluble_model_weights/v_48_010.pt && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/soluble_model_weights/v_48_020.pt && \
    echo "Downloaded soluble models:" && \
    ls -lh /app/ProteinMPNN/soluble_model_weights/*.pt

# Download CA-only model weights
RUN cd /app/ProteinMPNN/ca_model_weights && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/ca_model_weights/v_48_002.pt && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/ca_model_weights/v_48_010.pt && \
    wget -q https://files.ipd.uw.edu/pub/ProteinMPNN/ca_model_weights/v_48_020.pt && \
    echo "Downloaded CA-only models:" && \
    ls -lh /app/ProteinMPNN/ca_model_weights/*.pt

# Set working directory to ProteinMPNN
WORKDIR /app/ProteinMPNN

# Default command runs Python with protein_mpnn_run.py
CMD ["python", "/app/ProteinMPNN/protein_mpnn_run.py"]
