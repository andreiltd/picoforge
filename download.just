# Configuration
base_dir := justfile_directory()
downloads_dir := base_dir / "downloads"
tempdir := "/tmp"

# Version configuration
llvm_version := "llvmorg-21.1.0-rc1"
picolibc_version := "1.8.10-2"

# Repository URLs
llvm_repo := "https://github.com/llvm/llvm-project.git"
picolibc_repo := "https://github.com/picolibc/picolibc.git"

# Local directories
llvm_dir := downloads_dir / "llvm-project"
picolibc_dir := downloads_dir / "picolibc"

# Download all sources
all: llvm picolibc

# Download LLVM (skip if exists)
llvm:
    #!/bin/bash
    if [ ! -d "{{llvm_dir}}" ]; then
        echo "Downloading LLVM {{llvm_version}}..."
        git clone --depth 1 --branch {{llvm_version}} {{llvm_repo}} {{llvm_dir}}
    else
        echo "LLVM already downloaded"
    fi

# Download picolibc (skip if exists)
picolibc:
    #!/bin/bash
    if [ ! -d "{{picolibc_dir}}" ]; then
        echo "Downloading picolibc {{picolibc_version}}..."
        git clone --depth 1 --branch {{picolibc_version}} {{picolibc_repo}} {{picolibc_dir}}
    else
        echo "Picolibc already downloaded"
    fi

# Force re-download (ignores existence)
force: clean all

# Clean downloaded sources
clean:
    @echo "Cleaning downloaded sources..."
    rm -rf {{llvm_dir}} {{picolibc_dir}}

# Show download status
status:
    @echo "=== Download Status ==="
    @echo "Target versions: LLVM {{llvm_version}}, Picolibc {{picolibc_version}}"
    @if [ -d "{{llvm_dir}}" ]; then echo "✓ LLVM downloaded"; else echo "✗ LLVM missing"; fi
    @if [ -d "{{picolibc_dir}}" ]; then echo "✓ Picolibc downloaded"; else echo "✗ Picolibc missing"; fi
