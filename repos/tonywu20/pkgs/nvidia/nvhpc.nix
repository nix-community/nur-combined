{ stdenv
, lib
, autoPatchelfHook
, autoAddDriverRunpath
, fetchurl
, patchelf
, python3
, util-linux
, inetutils
, which
, glibc
, glib
, zlib
, zstd
, libxml2
, openmpi
, openssl
, ncurses6
, numactl
, rdma-core
, ucx
, libxcrypt-legacy
, gcc-unwrapped
}:
let
  platform = "Linux_x86_64";
in
stdenv.mkDerivation rec {
  pname = "nvidia-hpc-sdk";
  version = "25.7";
  name = "nvidia-hpc-sdk-${version}";

  src = fetchurl {
    url = "https://developer.download.nvidia.com/hpc-sdk/${version}/nvhpc_2025_257_Linux_x86_64_cuda_12.9.tar.gz";
    hash = "sha256-TGiO8rD3EBfebirB+4rM+5cKHCwSmxwBu6SZ/piwOSM=";
  };

  nativeBuildInputs = [ autoPatchelfHook autoAddDriverRunpath patchelf python3 util-linux inetutils which ];

  buildInputs = [
    openmpi
    stdenv.cc.cc.lib
    glibc
    glib
    zlib
    zstd
    libxml2.out
    openssl
    ncurses6
    numactl
    rdma-core
    (ucx.override { enableCuda = false; })
    libxcrypt-legacy
  ];

  dontConfigure = true;
  dontBuild = true;

  autoPatchelfIgnoreMissingDeps = [
    "libcuda.so.1"
    "libnvidia-ml.so.1"
    # Old libxml2 ABI (2.x) needed by NVHPC's LLVM toolchain
    "libxml2.so.2"
    # OpenSSL 1.1 ABI (nixpkgs provides 3.x)
    "libcrypto.so.1.1"
    # cuda-gdb (multi-python versions)
    "libgmp.so.10"
    "libpython3.10.so.1.0"
    "libpython3.11.so.1.0"
    "libpython3.12.so.1.0"
    "libpython3.8.so.1.0"
    "libpython3.9.so.1.0"
    # nvshmem / network tools
    "libpciaccess.so.0"
    "libcom_err.so.2"
    "libxpmem.so.0"
    "libgdrapi.so.2"
    # Profiler/debugger GUI libs (stripped but some traces remain)
    "libtiff.so.5"
  ];

  runtimeDependencies = [
    "${lib.getLib gcc-unwrapped.lib}"
    "${lib.getLib gcc-unwrapped.libgcc}"
    "${lib.getLib glib}"
    (placeholder "out")
    "${placeholder "out"}/cuda/nvvm"
    "${lib.getLib stdenv.cc.cc}/lib64"
    "${placeholder "out"}/cuda/lib64"
    "${placeholder "out"}/math_libs/lib64"
    "${placeholder "out"}/cuda/12.9/nvvm/lib64"
  ];

  patchPhase = ''
    patchShebangs --build ./install
    patchShebangs --build install_components/install*
  '';

  installPhase = ''
    mkdir -p $out
    export NVHPC_SILENT=true
    export NVHPC_INSTALL_DIR=$out
    ./install
    installDir=$out/${platform}/${version}
    if [ ! -d "$installDir" ]; then
      echo "ERROR: nvidia hpc-sdk installation not found at $installDir"
      exit 1
    fi
    # Remove large components not needed for compilation
    rm -rf "$installDir/profilers"
    rm -rf "$installDir/examples"
    # Remove dangling symlinks (profiler UI binaries deleted above)
    find "$installDir" -xtype l -delete
    # Patch shebangs in files copied by the installer
    patchShebangs --host "$installDir"
  '';

  # Configure NVHPC compiler to use nixpkgs' tools (detected from PATH
  # in the build sandbox) instead of system paths. This is needed so
  # nvfortran's internal linker script finds crt files via nix glibc.
  # Must run BEFORE autoPatchelfHook in fixupPhase.
  preFixup = ''
    nvBin=$out/${platform}/${version}/compilers/bin

    ${lib.getExe' patchelf "patchelf"} $out/lib64/libnvrtc.so --add-needed libnvrtc-builtins.so || true

    patchShebangs --host "$nvBin/makelocalrc"

    # Let makelocalrc auto-detect gcc/g++/gfortran from PATH
    $nvBin/makelocalrc $nvBin -x -q 2>&1

    # Fix localrc: move glibc includes to AFTER gcc headers in GCCINC
    # and GPPDIR so C++ #include_next <stdlib.h> works.
    python3 -c "
import re
glibc = '${glibc.dev}/include'
rcfile = '$nvBin/localrc'
with open(rcfile) as f:
    content = f.read()
for var in ['GCCINC', 'GPPDIR']:
    m = re.search(r'set ' + var + r'=(.*?);', content)
    if not m:
        continue
    parts = m.group(1).split()
    new_parts = [p for p in parts if p != glibc]
    new_parts.append(glibc)
    new_val = ' '.join(new_parts)
    content = content.replace(m.group(0), f'set {var}={new_val};')
with open(rcfile, 'w') as f:
    f.write(content)
"
  '';

  # postFixup runs AFTER autoPatchelfHook in the default fixupPhase.
  # autoPatchelfHook patches RPATH but doesn't always set the dynamic
  # linker. Do a final pass to ensure all ELFs have the correct
  # interpreter and re-patch makelocalrc's shebang.
  postFixup = ''
    dynamicLinker="$(cat $NIX_CC/nix-support/dynamic-linker)"
    find $out -type f \( -executable -o -name "*.so*" \) -print0 \
      | while IFS= read -r -d $'\0' file; do
        if isELF "$file"; then
          patchelf --set-interpreter "$dynamicLinker" "$file" 2>/dev/null || true
        fi
      done
    patchShebangs --host $out/${platform}/${version}/compilers/bin/makelocalrc
  '';

  passthru = {
    inherit version platform;
  };

  meta = with lib; {
    description = "NVIDIA HPC SDK (compilers, CUDA toolkit, MPI, math libraries)";
    homepage = "https://developer.nvidia.com/hpc-sdk";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.tonywu20 ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "nvfortran";
  };
}
