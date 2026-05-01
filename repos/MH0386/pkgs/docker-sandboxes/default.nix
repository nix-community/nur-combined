{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  lz4,
  xxhash,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "docker-sandboxes";
  version = "0.28.3";

  src =
    finalAttrs.passthru.sources.${stdenv.hostPlatform.system}
      or (throw "docker-sandboxes is not supported on ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    lz4
    stdenv.cc.cc.lib
    xxhash
    zlib
    zstd
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 sbx $out/bin/sbx

    install -Dm755 containerd-shim-nerdbox-v1 $out/libexec/containerd-shim-nerdbox-v1
    install -Dm755 mkfs.erofs $out/libexec/mkfs.erofs
    install -Dm755 libkrun.so $out/libexec/lib/libkrun.so

    install -Dm644 nerdbox-kernel-* -t $out/libexec
    install -Dm644 nerdbox-initrd-* -t $out/libexec
    install -Dm644 apparmor-profile $out/share/apparmor.d/docker-sbx-nerdbox-shim
    install -Dm644 LICENSE $out/share/licenses/${finalAttrs.pname}/LICENSE
    install -Dm644 THIRD-PARTY-NOTICES $out/share/doc/${finalAttrs.pname}/THIRD-PARTY-NOTICES

    runHook postInstall
  '';

  passthru = {
    sources = {
      x86_64-linux = fetchurl {
        url = "https://github.com/docker/sbx-releases/releases/download/v${finalAttrs.version}/DockerSandboxes-linux.tar.gz";
        hash = "sha256-vIAA2Z0NjSXcDTk71d/CHWf6O/COCGunCylN6RVqWDE=";
      };
    };
  };

  meta = {
    description = "Docker Sandboxes CLI";
    homepage = "https://docs.docker.com/ai/sandboxes";
    license = {
      fullName = "Docker Sandbox (sbx) - Proprietary Software";
      url = "https://www.docker.com/legal/docker-subscription-service-agreement";
      free = false;
    };
    platforms = [ "x86_64-linux" ];
    mainProgram = "sbx";
    maintainers = [ lib.maintainers.MH0386 ];
  };
})
