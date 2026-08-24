# Building
Helios binaries are built using [CMake](https://cmake.org) and requires `cmake` > 3.25.

## Building Locally

### Compiler
It is recommended to use one of the following compilers:

| Compiler    | Version |
|:------------|:--------|
| GCC         | 13+     |
| Clang       | 17+     |
| Apple Clang | 15+     |

### Dependencies

#### Linux
Dependencies vary by distribution. The authoritative package list is maintained in the
[Linux CI workflow](https://github.com/moonlight-os/helios/blob/main/.github/workflows/build.yml) and the packaging
files under `packaging/linux`.

##### CUDA Toolkit
Helios requires CUDA Toolkit for NVFBC capture. There are two caveats to CUDA:

1. The version installed depends on the version of GCC.
2. The version of CUDA you use will determine compatibility with various GPU generations.
   At the time of writing, the recommended version to use is CUDA ~12.9.
   See [CUDA compatibility](https://docs.nvidia.com/deploy/cuda-compatibility/index.html) for more info.

> [!NOTE]
> To install older versions, select the appropriate run file based on your desired CUDA version and architecture
> according to [CUDA Toolkit Archive](https://developer.nvidia.com/cuda-toolkit-archive)

#### macOS
You can either use [Homebrew](https://brew.sh) or [MacPorts](https://www.macports.org) to install dependencies.

##### Homebrew
```bash
dependencies=(
  "boost"  # Optional
  "cmake"
  "doxygen"  # Optional, for docs
  "graphviz"  # Optional, for docs
  "icu4c"  # Optional, if boost is not installed
  "miniupnpc"
  "ninja"
  "node"
  "openssl@3"
  "opus"
  "pkg-config"
)
brew install "${dependencies[@]}"
```

If there are issues with an SSL header that is not found:

@tabs{
  @tab{ Intel | ```bash
    ln -s /usr/local/opt/openssl/include/openssl /usr/local/include/openssl
    ```}
  @tab{ Apple Silicon | ```bash
    ln -s /opt/homebrew/opt/openssl/include/openssl /opt/homebrew/include/openssl
    ```
  }
}

##### MacPorts
```bash
dependencies=(
  "cmake"
  "curl"
  "doxygen"  # Optional, for docs
  "graphviz"  # Optional, for docs
  "libopus"
  "miniupnpc"
  "ninja"
  "npm9"
  "pkgconfig"
)
sudo port install "${dependencies[@]}"
```

#### Windows
First you need to install [MSYS2](https://www.msys2.org), then startup "MSYS2 UCRT64" and execute the following
commands.

##### Update all packages
```bash
pacman -Syu
```

##### Install dependencies
```bash
dependencies=(
  "git"
  "mingw-w64-ucrt-x86_64-boost"  # Optional, and currently pointless: the find is EXACT 1.89.0, MSYS2 ships 1.91.0
  "mingw-w64-ucrt-x86_64-cmake"
  "mingw-w64-ucrt-x86_64-cppwinrt"
  "mingw-w64-ucrt-x86_64-curl-winssl"
  "mingw-w64-ucrt-x86_64-doxygen"  # Optional, for docs... better to install official Doxygen
  "mingw-w64-ucrt-x86_64-graphviz"  # Optional, for docs
  "mingw-w64-ucrt-x86_64-MinHook"
  "mingw-w64-ucrt-x86_64-miniupnpc"
  "mingw-w64-ucrt-x86_64-ninja"  # The build below uses -G Ninja; the toolchain group does not include it
  "mingw-w64-ucrt-x86_64-nsis"
  "mingw-w64-ucrt-x86_64-onevpl"
  "mingw-w64-ucrt-x86_64-openssl"
  "mingw-w64-ucrt-x86_64-opus"
  "mingw-w64-ucrt-x86_64-toolchain"
  "mingw-w64-ucrt-x86_64-nlohmann_json"
)
pacman -S "${dependencies[@]}"
```

##### Install Node.js
Install Node.js separately from [nodejs.org](https://nodejs.org/) (LTS or current) or via
[nvm-windows](https://github.com/coreybutler/nvm-windows). Don't install MSYS2's
`mingw-w64-ucrt-x86_64-nodejs` — it's compiled with the MSYS2 gcc-16 libstdc++ which has
a `std::bad_weak_ptr` regression that crashes Node during process init (see
[apache/arrow#49958](https://github.com/apache/arrow/issues/49958) for the upstream
toolchain trail). The official MSVC-built Node.js isn't affected.

Make sure `node.exe` is on `PATH` before running `cmake` — the `web-ui` CMake target
invokes `npm install` via `find_program(NPM npm)`, so the official Node's `npm` must be
visible to CMake.

### Clone
Ensure [git](https://git-scm.com) is installed on your system, then clone the repository using the following command:

```bash
git clone https://github.com/moonlight-os/helios.git --recurse-submodules
cd helios
mkdir build
```

### Build

```bash
cmake -B build -G Ninja -S .
ninja -C build
```

> [!TIP]
> Available build options can be found in
> [options.cmake](https://github.com/moonlight-os/helios/blob/main/cmake/prep/options.cmake).

### Package

@tabs{
  @tab{Linux | @tabs{
    @tab{deb | ```bash
      cpack -G DEB --config ./build/CPackConfig.cmake
      ```}
    @tab{rpm | ```bash
      cpack -G RPM --config ./build/CPackConfig.cmake
      ```}
  }}
  @tab{macOS | @tabs{
    @tab{DragNDrop | ```bash
      cpack -G DragNDrop --config ./build/CPackConfig.cmake
      ```}
  }}
  @tab{Windows | @tabs{
    @tab{Installer | ```bash
      cpack -G NSIS --config ./build/CPackConfig.cmake
      ```}
    @tab{Portable | ```bash
      cpack -G ZIP --config ./build/CPackConfig.cmake
      ```}
  }}
}

### Remote Build
It may be beneficial to build remotely in some cases. This will enable easier building on different operating systems.

1. Fork the project
2. Activate workflows
3. Trigger the *CI* workflow manually
4. Download the artifacts/binaries from the workflow run summary

<div class="section_buttons">

| Previous                              |                            Next |
|:--------------------------------------|--------------------------------:|
| [Troubleshooting](troubleshooting.md) | [Contributing](contributing.md) |

</div>

<details style="display: none;">
  <summary></summary>
  [TOC]
</details>
