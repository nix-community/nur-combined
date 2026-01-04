{
  lib,
  sources,
  qemu_kvm,
  go,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:
# https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/pkgs/kata-runtime/default.nix
let
  yq-3_4_1 = buildGoModule rec {
    pname = "yq";
    version = "3.4.1";
    src = fetchFromGitHub {
      owner = "mikefarah";
      repo = "yq";
      rev = version;
      hash = "sha256-K3mWo5wFKWxSel8y/b6N02/BoB/KuTbHhVJrVYLCbCY=";
    };
    vendorHash = "sha256-jT0/4wjpj5kBULXIC+bupHOnp0n9sk4WJAC7hu6Cq1A=";
  };
in
stdenv.mkDerivation rec {
  pname = "kata-runtime";
  inherit (sources.kata-containers) version src;

  nativeBuildInputs = [ go ];

  dontConfigure = true;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "DEFAULT_HYPERVISOR=qemu"
    "HYPERVISORS=qemu"
    "QEMUPATH=${lib.getExe' qemu_kvm "qemu-system-x86_64"}"
  ];

  preBuild = ''
    cd src/runtime
    mkdir -p $TMPDIR/bin
    ln -s ${lib.getExe yq-3_4_1} $TMPDIR/bin/yq
    export HOME=$TMPDIR
    export GOPATH=$TMPDIR
  '';

  postInstall = ''
    ln -s $out/bin/containerd-shim-kata-v2 $out/bin/containerd-shim-kata-qemu-v2
    ln -s $out/bin/containerd-shim-kata-v2 $out/bin/containerd-shim-kata-clh-v2
    # qemu images don't work on read-only mounts, we need to put it into a mutable directory
    sed -i \
      -e "s!$out/share/kata-containers!/var/lib/kata-containers!" \
      -e "s!^virtio_fs_daemon.*!virtio_fs_daemon=\"${qemu_kvm}/libexec/virtiofsd\"!" \
      -e "s!^valid_virtio_fs_daemon_paths.*!valid_virtio_fs_daemon_paths=[\"${qemu_kvm}/libexec/virtiofsd\"]!" \
      "$out/share/defaults/kata-containers/"*.toml
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Open source project and community working to build a standard implementation of lightweight Virtual Machines (VMs) that feel and perform like containers, but provide the workload isolation and security advantages of VMs (Packaging script adapted from https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/pkgs/kata-runtime/default.nix)";
    homepage = "https://github.com/kata-containers/kata-containers";
    license = lib.licenses.asl20;
    knownVulnerabilities = [
      "${pname} is available in nixpkgs by a different maintainer"
    ];
    mainProgram = "kata-runtime";
  };
}
