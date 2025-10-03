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

# Clone ProteinMPNN repository and checkout specific commit for reproducibility
RUN git clone https://github.com/dauparas/ProteinMPNN.git /app/ProteinMPNN && \
    cd /app/ProteinMPNN && \
    git checkout 8907e6671bfbfc92303b5f79c4b5e6ce47cdef57

# Add ProteinMPNN to PATH so scripts can be called directly
ENV PATH="/app/ProteinMPNN:${PATH}"

# Set working directory to ProteinMPNN
WORKDIR /app/ProteinMPNN

# Default command runs Python with protein_mpnn_run.py
CMD ["python", "/app/ProteinMPNN/protein_mpnn_run.py"]
