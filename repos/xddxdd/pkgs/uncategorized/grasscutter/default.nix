{
  fetchgit,
  nix-update-script,
  stdenv,
  lib,
  fetchurl,
  jre_headless,
  procps,
  makeWrapper,
}:
let
  grasscutterResourcesSrc = fetchgit {
    url = "https://gitlab.com/YuukiPS/GC-Resources.git";
    rev = "6e83bd13ba95d07e017ebaf4037dbd76ac76fda7";
    fetchSubmodules = false;
    hash = "sha256-T2SApSv+UTezRoY9hwFVDr/Zaz5WVGK2QWSpRNeFI0w=";
  };

  resources = grasscutterResourcesSrc;
  keystore = fetchurl {
    url = "https://github.com/Grasscutters/Grasscutter/raw/development/keystore.p12";
    hash = "sha256-apFbGtWacE3GjXU/6h2yseskAsob0Xc/NWEu2uC0v3M=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "grasscutter";
  version = "1.7.4";
  src = fetchurl {
    url = "https://github.com/Grasscutters/Grasscutter/releases/download/v${finalAttrs.version}/grasscutter-${finalAttrs.version}.jar";
    hash = "sha256-tIYnCxtB14M+cGSuIZSZHworIzFEXKowyAgwmJ1jZpU=";
  };
  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    procps
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    install -Dm644 $src $out/grasscutter.jar

    ln -s ${resources}/Resources $out/opt/resources
    ln -s ${keystore} $out/opt/keystore.p12

    pushd $out/opt/
    # Without MongoDB, Grasscutter is expected to fail
    (${lib.getExe jre_headless} -jar $out/grasscutter.jar || true) | while read line; do
      [[ "''${line}" == *"Loading Grasscutter"* ]] && echo "Aborting loading" && pkill -9 java
      echo ''${line}
    done
    mv config.json config.example.json
    rm -rf logs
    popd

    makeWrapper ${lib.getExe jre_headless} $out/bin/grasscutter \
      --run "cp -r $out/opt/* ." \
      --run "chmod -R +rw ." \
      --add-flags "-jar" \
      --add-flags "$out/grasscutter.jar"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/Grasscutters/Grasscutter/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Server software reimplementation for a certain anime game";
    homepage = "https://github.com/Grasscutters/Grasscutter";
    license = with lib.licenses; [ agpl3Only ];
    mainProgram = "grasscutter";
  };
})
