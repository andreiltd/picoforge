# LLVM libcxx with Picolibc Build System

A simple build script for compiling LLVM's libcxx, libcxxabi, and libunwind against picolibc for bare-metal x86_64 targets.

## Overview

This project builds a freestanding C++ standard library suitable for hypervisors and embedded systems by combining:
- **LLVM's libcxx** - Modern C++ standard library implementation
- **Picolibc** - Lightweight C library for embedded systems
- **Cross-compilation** - Targeting `x86_64-unknown-none` bare-metal

## Prerequisites

- `clang` and `llvm` toolchain
- `meson` (version 0.50+) for picolibc
- `cmake` and `ninja` for LLVM
- `git` for downloading sources
- `just` command runner

## Quick Start

1. Clone or create this project structure
2. Run the complete build process:

```bash
just
```

This will:
- Download LLVM and picolibc sources
- Build picolibc with freestanding configuration
- Build LLVM libcxx, libcxx-abi and libunwind against picolibc
- Install everything to `install/`
