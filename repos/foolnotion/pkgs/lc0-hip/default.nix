{
  pkgs,
  rocmGpuTarget ? "gfx1201",
}:
let
  rocm = pkgs.rocmPackages;

  # lc0's meson.build invokes `hipcc` directly to compile its CUDA kernels for
  # AMD GPUs. nixpkgs' ROCm is not a merged /opt/rocm prefix, so hipcc cannot
  # find the clang to drive, the HIP runtime or the device libraries on its
  # own; wrap it once with all three spelled out.
  hipcc = pkgs.writeShellScriptBin "hipcc" ''
    export HIP_CLANG_PATH="${rocm.llvm.clang}/bin"
    exec ${rocm.hipcc}/bin/hipcc \
      --rocm-path="${rocm.clr}" \
      --rocm-device-lib-path="${rocm.rocm-device-libs}/amdgcn/bitcode" \
      "$@"
  '';
in
pkgs.lc0.overrideAttrs (old: {
  # First upstream release with the native HIP backend
  # (https://github.com/LeelaChessZero/lc0/pull/2420): lc0's own CUDA kernels
  # compiled with hipcc, no Intel DPC++/SYCL toolchain involved. Backends:
  # hip / hip-fp16 / hip-auto. Drop the src/postPatch overrides once nixpkgs'
  # lc0 moves past this commit.
  version = "unstable-2026-09-05";
  src = pkgs.fetchFromGitHub {
    owner = "LeelaChessZero";
    repo = "lc0";
    rev = "ef3310638ae39644cd8d3e1fd33f05e5fe797706";
    hash = "sha256-8TIeOz0nywy+JKy4w7ZU8U7qfI6t+iuRlyyjsNrRG/Y=";
    fetchSubmodules = true;
  };

  # Same eigen workaround nixpkgs' lc0 carries, matched to this source
  # revision's spelling of the check.
  postPatch = ''
    substituteInPlace meson.build \
      --replace-fail "if eigen_dep.found() and cc.has_header('Eigen/Core', dependencies: eigen_dep)" "if eigen_dep.found()"
  '';

  nativeBuildInputs = old.nativeBuildInputs ++ [ hipcc ];

  buildInputs = old.buildInputs ++ [
    rocm.clr
    rocm.hipblas
    rocm.rocblas
  ];

  mesonFlags = old.mesonFlags ++ [
    "-Dhip=true"
    "-Damd_gfx=${rocmGpuTarget}"
    # The HIP backend does not use cuDNN/MIOpen or CUTLASS fused attention
    # (see PR #2420): attention runs as the unfused hipBLAS path.
    "-Dcudnn=false"
    "-Dcutlass=false"
    "-Dgtest=false"
    # Upstream README requires b_lto=false for the HIP backend.
    "-Db_lto=false"
    "-Dhip_libdirs=['${rocm.hipblas}/lib','${rocm.clr}/lib']"
    "-Dhip_include=['${rocm.hipblas}/include','${rocm.hipblas-common}/include','${rocm.clr}/include']"
  ];

  doCheck = false;

  passthru = (old.passthru or { }) // {
    inherit rocmGpuTarget;
  };
})
