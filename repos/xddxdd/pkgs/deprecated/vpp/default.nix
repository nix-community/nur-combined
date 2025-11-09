{
  stdenv,
  sources,
  lib,
  cmake,
  ninja,
  pkg-config,
  # Dependencies
  dpdk,
  jansson,
  libbpf,
  libelf,
  libmnl,
  libnl,
  libpcap,
  mbedtls_2,
  openssl,
  python3,
  python3Packages,
  srtp,
  xdp-tools,
  zlib,
}:
let
  dpdk-vpp = dpdk.overrideAttrs (old: {
    mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Denable_driver_sdk=true" ];
  });
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.vpp) pname version src;
  sourceRoot = "source/src";

  postPatch = ''
    patchShebangs .

    cat > scripts/version <<EOF
      #!/bin/sh
      echo "${sources.vpp.version}"
    EOF

    cp ${./os-release} os-release
    sed -i "s#/etc/os-release#$(pwd)/os-release#g" pkg/CMakeLists.txt

    # Disable treat warnings as errors
    sed -i "/-g -Werror -Wall/d" CMakeLists.txt

    sed -i "s/libxdp.a/libxdp.so/g" plugins/af_xdp/CMakeLists.txt
    sed -i "s/libibverbs.a/libibverbs.so/g" plugins/rdma/CMakeLists.txt
    sed -i "s/libmlx5.a/libmlx5.so/g" plugins/rdma/CMakeLists.txt
    sed -i "s/libsrtp2.a/libsrtp2.so/g" plugins/srtp/CMakeLists.txt
  '';

  cmakeFlags = [ "-DVPP_USE_SYSTEM_DPDK=ON" ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];
  buildInputs = [
    dpdk-vpp
    jansson
    libbpf
    libelf
    libmnl
    libnl
    libpcap
    mbedtls_2
    openssl
    python3
    python3Packages.ply
    srtp
    xdp-tools
    zlib
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Vector Packet Processing";
    homepage = "https://wiki.fd.io/view/VPP/What_is_VPP%3F";
    license = lib.licenses.asl20;
    mainProgram = "vppctl";
    broken = true;
    knownVulnerabilities = [
      "${finalAttrs.pname} is available in nixpkgs"
    ];
  };
})
