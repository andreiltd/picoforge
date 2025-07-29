# Directory configuration
base_dir := justfile_directory()
downloads_dir := base_dir / "downloads"
install_dir := base_dir / "install"

clang_ver := "21"

# LLVM-specific directories
source_dir := downloads_dir / "llvm-project"
llvm_build_dir := base_dir / "build-llvm"
llvm_install_dir := install_dir / "libcxx"
picolibc_install_dir := install_dir / "libc"
builtin_incs_dir := llvm_build_dir + "/lib/clang/" + clang_ver + "/include"

target := "x86_64-unknown-none"

# Explicit macro definitions to avoid warnings
disabled_features := "-D_FORTIFY_SOURCE=0" + \
                     ";-D__loongarch__=0" + \
                     ";-D__SIZEOF_LONG_DOUBLE=0" + \
                     ";-D__STDC_WANT_LIB_EXT1__=0" + \
                     ";-D__HAVE_FAST_FMA=0" + \
                     ";-D__HAVE_FAST_FMAF=0" + \
                     ";-D__HAVE_FAST_FMAL=0"

enabled_features := "-D_GNU_SOURCE=1;-D_POSIX_C_SOURCE=200809L"

# Common compile flags
base_flags := "-ffreestanding;-nostdinc;-Wno-c++11-narrowing"
include_flags := "-I" + picolibc_install_dir + "/include" + ";-I" + builtin_incs_dir
compile_flags := enabled_features + ";" + disabled_features + ";" + base_flags + ";" + include_flags
c_compile_flags := compile_flags + ";-nostdinc"
cxx_compile_flags := compile_flags + ";-nostdinc++"

# Configure LLVM build
configure:
    @echo "Configuring LLVM libcxx..."
    @mkdir -p {{install_dir}}
    cmake -G Ninja -S {{source_dir}}/llvm -B {{llvm_build_dir}} \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
        -DLLVM_RUNTIME_TARGETS="{{target}}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="{{llvm_install_dir}}" \
        -DCMAKE_C_COMPILER_LAUNCHER="ccache" \
        -DCMAKE_CXX_COMPILER_LAUNCHER="ccache" \
        \
        -DRUNTIMES_{{target}}_COMPILER_RT_BAREMETAL_BUILD=ON \
        -DRUNTIMES_{{target}}_COMPILER_RT_BUILD_LIBFUZZER=OFF \
        -DRUNTIMES_{{target}}_COMPILER_RT_BUILD_PROFILE=OFF \
        -DRUNTIMES_{{target}}_COMPILER_RT_BUILD_SANITIZERS=OFF \
        -DRUNTIMES_{{target}}_COMPILER_RT_BUILD_XRAY=OFF \
        -DRUNTIMES_{{target}}_COMPILER_RT_DEFAULT_TARGET_ONLY=ON \
        \
        -DRUNTIMES_{{target}}_LIBCXX_ADDITIONAL_COMPILE_FLAGS="{{cxx_compile_flags}}" \
        -DRUNTIMES_{{target}}_LIBCXXABI_ADDITIONAL_COMPILE_FLAGS="{{cxx_compile_flags}}" \
        -DRUNTIMES_{{target}}_LIBUNWIND_ADDITIONAL_COMPILE_FLAGS="{{c_compile_flags}}" \
        \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_EXCEPTIONS=OFF \
        -DRUNTIMES_{{target}}_LIBCXXABI_ENABLE_EXCEPTIONS=OFF \
        -DRUNTIMES_{{target}}_LIBCXXABI_ENABLE_STATIC_UNWINDER=ON \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_FILESYSTEM=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_RANDOM_DEVICE=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_LOCALIZATION=ON \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_THREADS=OFF \
        -DRUNTIMES_{{target}}_LIBCXXABI_ENABLE_THREADS=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_HAS_PTHREAD_API=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_SHARED=OFF \
        -DRUNTIMES_{{target}}_LIBCXXABI_ENABLE_SHARED=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON \
        -DRUNTIMES_{{target}}_LIBCXX_USE_COMPILER_RT=ON \
        -DRUNTIMES_{{target}}_LIBCXXABI_USE_COMPILER_RT=ON \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_STDIO=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_WIDE_CHARACTERS=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_TIME_ZONE_DATABASE=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_HAS_MUSL_LIBC=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_HAS_TERMINAL_AVAILABLE=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_RTTI=OFF \
        -DRUNTIMES_{{target}}_LIBCXX_ENABLE_MONOTONIC_CLOCK=OFF \
        -DRUNTIMES_{{target}}_LIBCXXABI_BAREMETAL=ON \
        -DRUNTIMES_{{target}}_LIBUNWIND_ENABLE_THREADS=OFF \
        -DRUNTIMES_{{target}}_LIBUNWIND_ENABLE_SHARED=OFF \
        -DRUNTIMES_{{target}}_LIBUNWIND_USE_COMPILER_RT=ON \
        -DRUNTIMES_{{target}}_LIBUNWIND_IS_BAREMETAL=ON

# Build LLVM libcxx
build: configure
    @echo "Building LLVM libcxx..."
    ninja -C {{llvm_build_dir}} runtimes

# Install LLVM libcxx
install: build
    @echo "Installing LLVM libcxx..."
    ninja -C {{llvm_build_dir}} install-runtimes

# Clean LLVM build cache
clean:
    @echo "Cleaning LLVM build cache..."
    rm -rf {{llvm_build_dir}}/CMakeCache.txt

# Clean LLVM build
cleanall:
    @echo "Cleaning LLVM build..."
    rm -rf {{llvm_build_dir}}
    rm -rf {{llvm_install_dir}}

# Reconfigure LLVM
reconfigure: clean configure

# Show LLVM status
status:
    @echo "=== LLVM Status ==="
    @if [ -d "{{source_dir}}" ]; then \
        echo "✓ Source: {{source_dir}}"; \
    else \
        echo "✗ Source missing"; \
    fi
    @if [ -d "{{llvm_build_dir}}" ]; then \
        echo "✓ Build: {{llvm_build_dir}}"; \
    else \
        echo "✗ Build not configured"; \
    fi
    @if [ -d "{{llvm_install_dir}}" ]; then \
        echo "✓ Install: {{llvm_install_dir}}"; \
    else \
        echo "✗ Not installed"; \
    fi
