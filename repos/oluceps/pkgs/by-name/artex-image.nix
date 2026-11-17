{
  pkgs,
  lib,
  fetchFromGitHub,
  vmMemorySize ? 4096,
  vmDiskSize ? 20480,
}:
let
  src = fetchFromGitHub {
    owner = "failsafe-security";
    repo = "artex";
    rev = "b9e51d32922fd9768312a99d015b42bdc5697dd7";
    hash = "sha256-HLkzDqYuimCIB+zrnskwmOx6OltIM2v1rBmkPdBLq6c=";
  };
  containerfileNix = fetchFromGitHub {
    owner = "imincik";
    repo = "containerfile-nix";
    rev = "fdef9976c994685c3af3aa33e7a33a79a567ca59";
    hash = "sha256-F/amthB8HlA3ZHBlieb1n1HITkAY975/ZfUdYskSZLY=";
  };
  buildContainerFile = import "${containerfileNix}/build-containerfile.nix";
  imageName = "artex";
  imageTag = "v0.3.15-safe";
  # containerfile-nix mounts /tmp as a small tmpfs. Podman's image export
  # scratch space belongs on the VM's storage disk for this large image.
  podman = pkgs.writeShellScriptBin "podman" ''
    export TMPDIR=/var/lib/containerfile-tmp
    ${pkgs.coreutils}/bin/mkdir -p "$TMPDIR"
    ${pkgs.kmod}/bin/modprobe overlay
    exec ${pkgs.podman}/bin/podman --storage-driver=overlay "$@"
  '';
in
(buildContainerFile {
  inherit vmMemorySize vmDiskSize;
  pkgs = pkgs // {
    inherit podman;
  };
  name = imageName;
  tag = imageTag;
  script = builtins.readFile "${src}/Dockerfile.safe";
  buildContext = src;
  # Avoid retaining every intermediate container layer in the build VM.
  extraArgs = [
    "--format=docker"
    "--layers=false"
  ];
})
// {
  inherit src imageName imageTag;
  meta = {
    description = "ARTEX image built with upstream Dockerfile.safe via containerfile-nix";
    homepage = "https://github.com/failsafe-security/artex";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
}
