{ stdenvNoCC
, lib
, fetchurl
, fetchFromGitHub
, jre_headless
, makeWrapper
, writeScript
, ...
} @ args:

let
  version = "1.2.0";

  resources = fetchFromGitHub {
    owner = "Koko-boya";
    repo = "Grasscutter_Resources";
    rev = "6a4f84ecc688f51ea3046ee38bdf2f6b30e44726";
    sha256 = "sha256-QaWWlLjhzJL5jtbng4UWMz/tPCyYwPKIUbGT36ws7Hc=";
  };

  keystore = fetchurl {
    url = "https://github.com/Grasscutters/Grasscutter/raw/development/keystore.p12";
    sha256 = "sha256-apFbGtWacE3GjXU/6h2yseskAsob0Xc/NWEu2uC0v3M=";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "grasscutter";
  inherit version;

  # Right now Nixpkgs cannot handle building jars with gradle
  src = fetchurl {
    url = "https://github.com/Grasscutters/Grasscutter/releases/download/v${version}/grasscutter-${version}.jar";
    sha256 = "sha256-Xof3BeXp9Em3TXBpqrbtrYCTorBQZF/23LXH21WmfoI=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = let
    languageScript = writeScript "language.sh" ''
      echo "en"
      echo "en"
    '';
  in ''
    mkdir -p $out/bin $out/opt
    cp ${src} $out/grasscutter.jar

    ln -s ${resources}/Resources $out/opt/resources
    ln -s ${keystore} $out/opt/keystore.p12

    pushd $out/opt/
    ${languageScript} | ${jre_headless}/bin/java -jar $out/grasscutter.jar -handbook
    mv config.json config.example.json
    rm -rf logs
    popd

    makeWrapper ${jre_headless}/bin/java $out/bin/grasscutter \
      --run "cp -r $out/opt/* ." \
      --run "chmod -R +rw ." \
      --add-flags "-jar" \
      --add-flags "$out/grasscutter.jar" \
  '';

  meta = with lib; {
    description = "A server software reimplementation for a certain anime game.";
    homepage = "https://github.com/Grasscutters/Grasscutter";
  };
}
