base_dir := justfile_directory()
install_dir := base_dir / "dist"
tempdir := "/tmp"

mod picolibc
mod llvm

# Default recipe - build everything
default: build

# Initialize and update submodules with full clones
init-submodules:
    @echo "Initializing submodules..."
    git submodule update --init --recursive

# Setup directories
setup:
    @echo "Setting up build environment..."
    mkdir -p {{install_dir}}

[private]
[confirm('proceed?')]
do-clean:
    @echo "Cleaning all build artifacts..."
    rm -rf {{install_dir}}
    rm -rf build-picolibc
    rm -rf build-llvm

# Clean everything
cleanall: && do-clean
    @echo "This will remove {{install_dir}} and all build directories."

# Show status of all components
status:
    @echo "=== Build Environment Status ==="
    @echo "Base directory: {{base_dir}}"
    @echo "Install: {{install_dir}}"
    @echo ""
    just picolibc::status
    @echo ""
    just llvm::status

build: init-submodules setup && status
    just picolibc::install
    just llvm::install
