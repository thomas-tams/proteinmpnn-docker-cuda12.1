# ProteinMPNN Docker Image (CUDA 12.1)

Optimized Docker image for ProteinMPNN with NVIDIA CUDA 12.1 support, pre-configured with all dependencies and model checkpoints.

## Features

- **Base Image**: PyTorch 2.3.1 with CUDA 12.1 and cuDNN 8 (runtime)
- **No Conda**: Pure pip-based installation for smaller image size and better GPU compatibility
- **PyTorch**: 2.3.1 with CUDA 12.1 support (pre-installed with torchvision and torchaudio)
- **Pre-installed**: ProteinMPNN repository with all scripts
- **Model Checkpoints**: All model weights pre-downloaded
  - Vanilla models (v_48_002, v_48_010, v_48_020, v_48_030)
  - Soluble models (v_48_010, v_48_020)
  - CA-only models (v_48_002, v_48_010, v_48_020)
- **GPU Verified**: Compatible with NVIDIA Driver 450.80.02 or higher

## Models Included

### Vanilla Model Weights (`/app/ProteinMPNN/vanilla_model_weights/`)
- v_48_002.pt
- v_48_010.pt
- v_48_020.pt
- v_48_030.pt

### Soluble Model Weights (`/app/ProteinMPNN/soluble_model_weights/`)
- v_48_010.pt
- v_48_020.pt

### CA-only Model Weights (`/app/ProteinMPNN/ca_model_weights/`)
- v_48_002.pt
- v_48_010.pt
- v_48_020.pt

## Requirements

- Docker with NVIDIA GPU support
- NVIDIA Container Toolkit installed on host
- NVIDIA GPU with CUDA capability
- NVIDIA Driver version 450.80.02 or higher

## Installation

### Build Locally

```bash
git clone <your-repo-url>
cd proteinmpnn-docker-cuda12.1
docker build -t proteinmpnn-cuda12.1 .
```

### Test CUDA Availability

```bash
docker run --rm --gpus all proteinmpnn-cuda12.1 python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

## Usage

### Basic Protein Design

Design sequences for a protein structure:

```bash
docker run --gpus all \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  proteinmpnn-cuda12.1 \
  python /app/ProteinMPNN/protein_mpnn_run.py \
    --pdb_path /app/input/input.pdb \
    --out_folder /app/output \
    --num_seq_per_target 10 \
    --sampling_temp 0.1
```

### Using Specific Model Weights

Use a specific model checkpoint:

```bash
docker run --gpus all \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  proteinmpnn-cuda12.1 \
  python /app/ProteinMPNN/protein_mpnn_run.py \
    --pdb_path /app/input/input.pdb \
    --out_folder /app/output \
    --model_name v_48_020 \
    --num_seq_per_target 10 \
    --sampling_temp 0.1
```

### Fixed Backbone Design with Position Constraints

Design with specific residues fixed:

```bash
docker run --gpus all \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  proteinmpnn-cuda12.1 \
  python /app/ProteinMPNN/protein_mpnn_run.py \
    --pdb_path /app/input/input.pdb \
    --out_folder /app/output \
    --num_seq_per_target 10 \
    --sampling_temp 0.1 \
    --seed 37 \
    --batch_size 1
```

### Multi-chain Protein Design

Design sequences for multi-chain complexes:

```bash
docker run --gpus all \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  proteinmpnn-cuda12.1 \
  python /app/ProteinMPNN/protein_mpnn_run.py \
    --pdb_path /app/input/complex.pdb \
    --out_folder /app/output \
    --num_seq_per_target 10 \
    --sampling_temp 0.1
```

### Using Soluble Model Weights

For designing soluble proteins:

```bash
docker run --gpus all \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  proteinmpnn-cuda12.1 \
  python /app/ProteinMPNN/protein_mpnn_run.py \
    --pdb_path /app/input/input.pdb \
    --out_folder /app/output \
    --path_to_model_weights /app/ProteinMPNN/soluble_model_weights \
    --model_name v_48_020 \
    --num_seq_per_target 10 \
    --sampling_temp 0.1
```

### Using CA-only Models

For C-alpha only backbone designs:

```bash
docker run --gpus all \
  -v $(pwd)/input:/app/input \
  -v $(pwd)/output:/app/output \
  proteinmpnn-cuda12.1 \
  python /app/ProteinMPNN/protein_mpnn_run.py \
    --pdb_path /app/input/ca_only.pdb \
    --out_folder /app/output \
    --path_to_model_weights /app/ProteinMPNN/ca_model_weights \
    --ca_only \
    --num_seq_per_target 10 \
    --sampling_temp 0.1
```

### Interactive Shell

Access the container interactively:

```bash
docker run --gpus all -it \
  --entrypoint /bin/bash \
  proteinmpnn-cuda12.1
```

### Use in Nextflow

```groovy
process PROTEINMPNN_DESIGN {
    container 'proteinmpnn-cuda12.1:latest'
    containerOptions '--gpus all'

    input:
    tuple val(meta), path(input_pdb)

    output:
    tuple val(meta), path("${meta.id}/*.fa"), emit: sequences
    tuple val(meta), path("${meta.id}/*_scores.npz"), emit: scores

    script:
    """
    mkdir -p ${meta.id}
    python /app/ProteinMPNN/protein_mpnn_run.py \
      --pdb_path ${input_pdb} \
      --out_folder ${meta.id} \
      --num_seq_per_target ${params.num_designs} \
      --sampling_temp ${params.sampling_temp}
    """
}
```

### Use with Apptainer/Singularity

```bash
# Build from local Docker image
apptainer build proteinmpnn.sif docker-daemon://proteinmpnn-cuda12.1:latest

# Run design
apptainer run --nv proteinmpnn.sif \
  python /app/ProteinMPNN/protein_mpnn_run.py \
  --pdb_path input/input.pdb \
  --out_folder output \
  --num_seq_per_target 10 \
  --sampling_temp 0.1
```

## Common Parameters

- `--pdb_path`: Input PDB file path
- `--out_folder`: Output directory for generated sequences
- `--num_seq_per_target`: Number of sequences to generate per design
- `--sampling_temp`: Temperature for sampling (lower = more confident predictions)
- `--seed`: Random seed for reproducibility
- `--batch_size`: Batch size for inference
- `--model_name`: Specific model to use (v_48_002, v_48_010, v_48_020, v_48_030)
- `--path_to_model_weights`: Path to model weights directory
- `--ca_only`: Use CA-only model (for C-alpha backbones)

## Environment Details

- **Python Version**: 3.10 (from PyTorch base image)
- **ProteinMPNN Location**: `/app/ProteinMPNN`
- **Model Weights Locations**:
  - Vanilla: `/app/ProteinMPNN/vanilla_model_weights`
  - Soluble: `/app/ProteinMPNN/soluble_model_weights`
  - CA-only: `/app/ProteinMPNN/ca_model_weights`
- **Working Directory**: `/app/ProteinMPNN`

## Troubleshooting

### CUDA Unknown Error

If you encounter "CUDA unknown error" when running the container:

1. **Reboot your system** - GPU state issues from suspend/resume can cause this
2. **Enable persistence mode**: `sudo nvidia-smi -pm 1`
3. **Verify GPU is accessible**: `docker run --rm --gpus all nvidia/cuda:12.1.0-runtime-ubuntu22.04 nvidia-smi`

### GPU Not Detected

Ensure NVIDIA Container Toolkit is properly installed:

```bash
# Install NVIDIA Container Toolkit (Ubuntu/Debian)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

## Architecture Improvements

This optimized version provides several improvements:

- **Smaller Image Size**: Uses runtime base image instead of devel, no conda overhead
- **Better GPU Compatibility**: No LD_LIBRARY_PATH conflicts between conda and NVIDIA runtime
- **Faster Builds**: PyTorch pre-installed, no conda environment creation
- **Simpler Maintenance**: Pure pip dependencies, standard Python packaging
- **All Models Pre-downloaded**: No need to download models separately

## License

This Docker image packages ProteinMPNN, which is licensed under its own terms. Please refer to the [ProteinMPNN repository](https://github.com/dauparas/ProteinMPNN) for license information.

## References

- [ProteinMPNN GitHub](https://github.com/dauparas/ProteinMPNN)
- [ProteinMPNN Paper](https://www.science.org/doi/10.1126/science.add2187) - Dauparas et al. (2022), Science
- [PyTorch Docker Hub](https://hub.docker.com/r/pytorch/pytorch)

## Citation

If you use ProteinMPNN, please cite:

```
Dauparas, J., Anishchenko, I., Bennett, N. et al.
Robust deep learning–based protein sequence design using ProteinMPNN.
Science 378, 49-56 (2022).
DOI: 10.1126/science.add2187
```
