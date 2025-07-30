base_dir := justfile_directory()
downloads_dir := base_dir / "downloads"
install_dir := base_dir / "install"

# Picolibc-specific directories
source_dir := downloads_dir / "picolibc"
picolibc_build_dir := base_dir / "build-picolibc"
picolibc_install_dir := install_dir / "libc"

target := "x86_64-unknown-none"

# Configure picolibc build
configure:
    @echo "Configuring picolibc..."
    @mkdir -p {{picolibc_install_dir}}
    meson setup --wipe {{picolibc_build_dir}} {{source_dir}} \
        --cross-file={{base_dir}}/cross-{{target}}.txt \
        --buildtype=release \
        -Dprefix={{picolibc_install_dir}} \
        -Dmultilib=false \
        -Dformat-default=minimal \
        -Dposix-console=false \
        -Dprintf-aliases=false \
        -Dpicocrt=false \
        -Dinitfini-array=false \
        -Dsingle-thread=true \
        -Denable-malloc=false \
        -Dnewlib-nano-malloc=false \
        -Dthread-local-storage=false \
        -Dnewlib-global-errno=true \
        -Dtests=false \
        -Dsemihost=false \
        -Dspecsdir=none \
        -Dtinystdio=true \
        -Dio-c99-formats=false \
        -Dio-wchar=true \
        -Dfreestanding=true

# Build picolibc
build: configure
    @echo "Building picolibc..."
    ninja -C {{picolibc_build_dir}}

# Install picolibc only
install: build
    @echo "Installed to {{picolibc_install_dir}}"
    ninja -C {{picolibc_build_dir}} install

clean:
    @echo "Cleaning picolibc build artifacts..."
    meson compile --clean -C {{picolibc_build_dir}}

# Clean picolibc build
cleanall:
    @echo "Cleaning picolibc build..."
    rm -rf {{picolibc_build_dir}}
    rm -rf {{picolibc_install_dir}}

# Reconfigure picolibc
reconfigure: clean configure

# Show picolibc status
status:
    @echo "=== Picolibc Status ==="
    @if [ -d "{{source_dir}}" ]; then \
        echo "✓ Source: {{source_dir}}"; \
    else \
        echo "✗ Source missing"; \
    fi
    @if [ -d "{{picolibc_build_dir}}" ]; then \
        echo "✓ Build: {{picolibc_build_dir}}"; \
    else \
        echo "✗ Build not configured"; \
    fi
    @if [ -d "{{picolibc_install_dir}}" ]; then \
        echo "✓ Install: {{picolibc_install_dir}}"; \
    else \
        echo "✗ Not installed"; \
    fi
