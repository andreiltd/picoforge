base_dir := justfile_directory()
downloads_dir := base_dir / "downloads"
install_dir := base_dir / "install"
tempdir := "/tmp"

mod download
mod picolibc
mod llvm

# Default recipe - build everything
default: build

# Setup directories
setup:
    @echo "Setting up build environment..."
    mkdir -p {{downloads_dir}}
    mkdir -p {{install_dir}}

[private]
[confirm('proceed?')]
do-clean:
    @echo "Cleaning all build artifacts..."
    rm -rf {{downloads_dir}}
    rm -rf {{install_dir}}
    rm -rf build-picolibc
    rm -rf build-llvm

# Clean everything
cleanall: && do-clean
    @echo "This will remove {{downloads_dir}} and {{install_dir}}"

# Show status of all components
status:
    @echo "=== Build Environment Status ==="
    @echo "Base directory: {{base_dir}}"
    @echo "Downloads: {{downloads_dir}}"
    @echo "Install: {{install_dir}}"
    @echo ""
    just download::status
    @echo ""
    just picolibc::status
    @echo ""
    just llvm::status

build: setup
    just --tempdir={{tempdir}} download::all
    just picolibc::install
    just llvm::install
