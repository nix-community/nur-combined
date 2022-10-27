{ stdenv, pkgs, lib,
runtimeShell, python3,
enableDpdk ? true,
enableRdma ? true,
enableAfXdp ? false}:

stdenv.mkDerivation rec {
  name = "vpp-${version}";
  version = "22.10-rc2";
  src = pkgs.fetchFromGitHub {
    owner = "FDio";
    repo = "vpp";
    rev = "v${version}"; #"61bae8a54d14899337b0d0a7ca9b9367f6321951";
    hash = "sha256-3b+cnEjbReCg+svVD4DZwgcLwoA/IDWTGoP9ALYZFR4=";
  };
  sourceRoot = "source/src";

  nativeBuildInputs = with pkgs; [ pkg-config cmake ninja nasm coreutils ];
  buildInputs = with pkgs; [
    libconfuse numactl libuuid
    libffi openssl

    python3.pkgs.wrapPython(python3.withPackages (pp: with pp; [
      ply # for vppapigen
    ]))

    # linux-cp deps
    libnl libmnl
  ]
  # dpdk plugin
  ++ lib.optional enableDpdk [ dpdk libpcap jansson ]
  # rdma plugin - Mellanox/NVIDIA ConnectX-4+ device driver. Needs overridden rdma-core with static libs.
  ++ lib.optional enableRdma (rdma-core.overrideAttrs (x: {
    cmakeFlags = x.cmakeFlags ++ [ "-DENABLE_STATIC=1" "-DBUILD_SHARED_LIBS:BOOL=false"];
  }))
  # af_xdp deps - broken: af_xdp plugins - no working libbpf found - af_xdp plugin disabled
  ++ lib.optional enableAfXdp libbpf
  # Shared deps for DPDK and AF_XDP
  ++ lib.optional (enableDpdk || enableAfXdp) libelf;

  # Needs a few patches.
  patchPhase = ''
    # This attempts to use git to fetch the version, but we already know it.
    printf "#!${runtimeShell}\necho '${version}'\n" > scripts/version
    chmod +x scripts/version

    # Nix has no /etc/os-release.
    substituteInPlace pkg/CMakeLists.txt --replace 'file(READ "/etc/os-release" os_release)' 'set(os_release "NAME=NIX; ID=nix")'

    patchShebangs .
  '';

  enableParallelBuilding = true;
  cmakeFlags = [ 
    "-DCMAKE_INSTALL_LIBDIR=lib" # wants a relative path
    
    # For debugging CMake:
    #"--trace-source=CMakeLists.txt"
    #"--trace-expand"
  ]
  # Link against system DPDK. Note that this is actually statically linked as well.
  ++ lib.optional enableDpdk "-DVPP_USE_SYSTEM_DPDK=true";

  # TODO: Add service
  # TODO: Add users/group for default config.
  # TODO: RDMA plugin - needs libibverbs.a, can probably get that from rdma-core if not removing static libs?
}
