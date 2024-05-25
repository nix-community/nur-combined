{
  lib,
  stdenv,
  fetchfromgh,
  undmg,
}:

let
  arch =
    {
      "aarch64-darwin" = "arm64";
      "x86_64-darwin" = "x64";
    }
    .${stdenv.hostPlatform.system};
  hash =
    {
      "aarch64-darwin" = "sha256-3+Lib7gWF03UrIKRcyzHw9aX79aebkCQscAPdKAf6z0=";
      "x86_64-darwin" = "sha256-miIw5xsL6GSHC+sX3JNxktfwhY5tkLrLCNdHHUwdtdY=";
    }
    .${stdenv.hostPlatform.system};
in
stdenv.mkDerivation (finalAttrs: {
  pname = "podman-desktop";
  version = "1.7.0";

  src = fetchfromgh {
    owner = "containers";
    repo = "podman-desktop";
    name = "podman-desktop-${finalAttrs.version}-${arch}.dmg";
    version = "v${finalAttrs.version}";
    inherit hash;
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    cp -R *.app $out/Applications
    runHook postInstall
  '';

  meta = {
    description = "A graphical tool for developing on containers and Kubernetes";
    homepage = "https://podman-desktop.io/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.asl20;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
