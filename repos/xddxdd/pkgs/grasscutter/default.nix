{ stdenv
, lib
, fetchurl
, fetchFromGitHub
, jre_headless
, makeWrapper
, ...
} @ args:

let
  version = "1.1.0";

  genshinData = fetchFromGitHub {
    owner = "Dimbreath";
    repo = "GenshinData";
    rev = "a83df7fcbcc26b2fc3d2918354caaaf223a40611";
    sha256 = "sha256-2SVcVmjzGZJdW4m3S2q6+YyUhaqZns4N2AxtoXTPrIU=";
  };

  giBinOutput = fetchFromGitHub {
    owner = "zhsitao";
    repo = "gi-bin-output";
    rev = "52dc851aef57c28217f4d5c54ba4cf93ac8f36b3";
    sha256 = "sha256-82IH8K79qZTK2LPkNGEtT0FQEnJfp2Cez6O5ffSrhxc=";
  };

  srcRepo = fetchFromGitHub {
    owner = "Grasscutters";
    repo = "Grasscutter";
    rev = "v${version}";
    sha256 = "sha256-f1y5Ojhcyy2A+bb0UaJB9SaK6A4E3h2Mv5NS0iOcBzQ=";
  };
in
stdenv.mkDerivation rec {
  pname = "grasscutter";
  inherit version;

  # Right now Nixpkgs cannot handle building jars with gradle
  src = fetchurl {
    url = "https://github.com/Grasscutters/Grasscutter/releases/download/v${version}/grasscutter-${version}.jar";
    sha256 = "sha256-643P7Ems+W/VpJXGGPXUOja3le7wKx2GPcYxATRDQDY=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/opt/resources
    cp ${src} $out/grasscutter.jar

    ln -s ${giBinOutput}/2.5.52/Data/_BinOutput $out/opt/resources/BinOutput
    ln -s ${genshinData}/ExcelBinOutput $out/opt/resources/ExcelBinOutput
    ln -s ${genshinData}/Readable $out/opt/resources/Readable
    ln -s ${genshinData}/Subtitle $out/opt/resources/Subtitle
    ln -s ${genshinData}/TextMap $out/opt/resources/TextMap
    ln -s ${srcRepo}/keys $out/opt/keys
    ln -s ${srcRepo}/keystore.p12 $out/opt/keystore.p12
    cp -r ${srcRepo}/data $out/opt/data

    pushd $out/opt/
    echo "en" | ${jre_headless}/bin/java -jar $out/grasscutter.jar -handbook
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
