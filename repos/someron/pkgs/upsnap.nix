{
  stdenv, lib,
  fetchzip,
}:
let
  version = "5.2.7";
  artifacts = {
    aarch64-linux = {
      systemName = "linux_armv64";
      hash = "sha256-6ELo0bIc0G1Dm8xquNmVWQ4yxEk3CAIit1rbyAJTY9M=";
    };
    x86_64-linux = {
      systemName = "linux_amd64";
      hash = "sha256-m5PLdMGGh8QDQH+gVBUpUUXICjcqvHSSg3FefnTKi+c=";
    };
    aarch64-darwin = {
      systemName = "darwin_arm64";
      hash = "sha256-MdkMFd3wV3nBdG8nZS0Ueur6n5wODbZB4CnnrpfyRmY=";
    };
    x86_64-darwin = {
      systemName = "darwin_amd64";
      hash = "sha256-ufXP/yw2tpDPpkN6u0zkMlDFPNWfwRD9vuUAnQhajvk=";
    };
  };
  artifact = artifacts.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "upsnap";
  version = version;

  meta = {
    description = "A simple wake on lan web app written with SvelteKit, Go and PocketBase.";
    homepage = "https://github.com/seriousm4x/UpSnap";
    license = lib.licenses.mit;
    mainProgram = "upsnap";
    platforms = lib.attrNames artifacts;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };

  src = fetchzip {
    url = "https://github.com/seriousm4x/UpSnap/releases/download/${version}/UpSnap_${version}_${artifact.systemName}.zip";
    hash = artifact.hash;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 $src/upsnap $out/bin/upsnap

    runHook postInstall
  '';
}
