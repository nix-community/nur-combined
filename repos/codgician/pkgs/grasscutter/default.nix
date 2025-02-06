{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  genshin-data,
  jre_headless,
  procps,
  makeWrapper,
  gradle_7,
  stripJavaArchivesHook,
  nix-update-script,
  grasscutter,
}:

stdenvNoCC.mkDerivation rec {
  pname = "grasscutter";
  version = "1.7.4-unstable-2024-11-23";

  src = fetchFromGitHub {
    owner = "Grasscutters";
    repo = pname;
    rev = "9c36daa3fa8be5f9ec26fbb2b36f3e1dceff977d";
    hash = "sha256-EHPCxT1s8JHd8ABxqwVRfsIq6yPuM2wmGknECpByyXc=";
  };

  nativeBuildInputs = [
    makeWrapper
    procps
    gradle_7
    stripJavaArchivesHook
  ];

  gradleBuildTask = "jar";

  mitmCache = gradle_7.fetchDeps {
    pkg = grasscutter;
    data = ./deps.json;
  };

  postPatch = ''
    patchShebangs .
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt
    cp ./grasscutter*.jar $out/grasscutter.jar

    ln -s ${genshin-data.outPath} $out/opt/resources
    ln -s ${src}/keystore.p12 $out/opt/keystore.p12

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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=development"
    ];
  };

  meta = {
    description = "Server software reimplementation for a certain anime game";
    homepage = "https://github.com/Grasscutters/Grasscutter";
    license = with lib.licenses; [ agpl3Only ];
    maintainers = with lib.maintainers; [ codgician ];
    platforms = lib.platforms.linux;
    mainProgram = "grasscutter";
  };
}
