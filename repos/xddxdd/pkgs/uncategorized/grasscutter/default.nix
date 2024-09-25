{
  stdenvNoCC,
  lib,
  sources,
  fetchurl,
  jre_headless,
  procps,
  makeWrapper,
  ...
}:
let
  resources = sources.grasscutter-resources.src;
  keystore = fetchurl {
    url = "https://github.com/Grasscutters/Grasscutter/raw/development/keystore.p12";
    hash = "sha256-apFbGtWacE3GjXU/6h2yseskAsob0Xc/NWEu2uC0v3M=";
  };
in
stdenvNoCC.mkDerivation rec {
  inherit (sources.grasscutter) pname version src;

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
    (${jre_headless}/bin/java -jar $out/grasscutter.jar || true) | while read line; do
      [[ "''${line}" == *"Loading Grasscutter"* ]] && echo "Aborting loading" && pkill -9 java
      echo ''${line}
    done
    mv config.json config.example.json
    rm -rf logs
    popd

    makeWrapper ${jre_headless}/bin/java $out/bin/grasscutter \
      --run "cp -r $out/opt/* ." \
      --run "chmod -R +rw ." \
      --add-flags "-jar" \
      --add-flags "$out/grasscutter.jar"

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "A server software reimplementation for a certain anime game.";
    homepage = "https://github.com/Grasscutters/Grasscutter";
    license = with licenses; [ agpl3Only ];
  };
}
