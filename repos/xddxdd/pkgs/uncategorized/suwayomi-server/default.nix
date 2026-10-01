{
  fetchurl,
  nix-update-script,
  stdenv,
  lib,
  unzip,
  jre_headless,
  makeWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "suwayomi-server";
  version = "2.4.2366";
  src = fetchurl {
    url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v${finalAttrs.version}/Suwayomi-Server-v${finalAttrs.version}.jar";
    hash = "sha256-r5/rIK+dfr6eMHaebG68f8erHERziNQuAoCx2l/ge/0=";
  };
  dontUnpack = true;

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/opt/suwayomi-server.jar

    mkdir -p $out/bin
    makeWrapper ${lib.getExe jre_headless} $out/bin/suwayomi-server \
      --add-flags "-jar" \
      --add-flags "$out/opt/suwayomi-server.jar"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/Suwayomi/Suwayomi-Server/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Rewrite of Tachiyomi for the Desktop";
    homepage = "https://github.com/Suwayomi/Suwayomi-Server";
    license = lib.licenses.mpl20;
    mainProgram = "suwayomi-server";
  };
})
