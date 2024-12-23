{
  lib,
  stdenv,
  fetchfromgh,
  _7zz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "podman-desktop";
  version = "1.15.0";

  src = fetchfromgh {
    owner = "containers";
    repo = "podman-desktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TS2232oa7lnDh4E3F3Z3y2IGX2Q/SRV/tWIlvgpBkEU=";
    name = "podman-desktop-${finalAttrs.version}-x64.dmg";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ _7zz ];
  unpackCmd = "7zz x $curSrc";

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
    platforms = [ "x86_64-darwin" ];
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = true;
  };
})
