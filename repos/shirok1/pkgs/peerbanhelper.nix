{
  lib,
  stdenv,
  pkgs,
  makeWrapper,
  jdk25_headless,
  ...
}:
let
  pname = "peerbanhelper";
  version = "9.2.3";
in
stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchzip {
    url = "https://github.com/PBH-BTN/PeerBanHelper/releases/download/v${version}/PeerBanHelper_${version}.zip";
    sha256 = "sha256-j8gB2T5Ymc4jLg/RTvtXsW/xvzyxEvb6JSPcJq+fJxY=";
  };

  nativeBuildInputs = [
    makeWrapper
    jdk25_headless
  ];

  installPhase = ''
    # create the bin directory
    mkdir -p $out/bin

    # create a wrapper that will automatically set the classpath
    # this should be the paths from the dependency derivation
    makeWrapper ${jdk25_headless}/bin/java $out/bin/${pname} \
        --add-flags "-cp $src/libraries -jar $src/PeerBanHelper.jar"
  '';

  meta = with lib; {
    description = "Automatically block unwanted, leeches and abnormal BT peers with support for customized and cloud rules.";
    homepage = "https://github.com/PBH-BTN/PeerBanHelper";
    license = licenses.gpl3Only;
    sourceProvenance = [ sourceTypes.binaryBytecode ];
    mainProgram = pname;
  };
}
