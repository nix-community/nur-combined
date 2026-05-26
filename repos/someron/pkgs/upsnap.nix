{
  stdenv, lib,
  fetchzip,
}:
let
  version = "5.3.5";
  artifacts = {
    aarch64-linux = {
      systemName = "linux_arm64";
      hash = "sha256-ZXak9h54IMvPJzFY69TkMAbz505IWxDFSgeAFJLokRw=";
    };
    x86_64-linux = {
      systemName = "linux_amd64";
      hash = "sha256-Y/GNtST16AMwW98N+jixJWcOWi3RW0Qda7WeMdMcKfQ=";
    };
    aarch64-darwin = {
      systemName = "darwin_arm64";
      hash = "sha256-3j0UZ0TcW/tyH7ZeChx0ILbH/2UYdvsMohrkuDbxulQ=";
    };
    x86_64-darwin = {
      systemName = "darwin_amd64";
      hash = "sha256-eI0YIaAw296kqhx5hkYXXIARQf9IMzJthDhhq01kkMg=";
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
