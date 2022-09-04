{ lib, stdenv, fetchfromgh, unzip }:

stdenv.mkDerivation rec {
  pname = "MacPass-bin";
  version = "0.8.1";

  src = fetchfromgh {
    owner = "MacPass";
    repo = "MacPass";
    name = "MacPass-${version}.zip";
    hash = "sha256-LQ073JRbQsDB/nmx63Tllptfdo/8VqoobXPTSShzsXM=";
    inherit version;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  preferLocalBuild = true;

  meta = with lib; {
    description = "A native OS X KeePass client";
    homepage = "https://macpassapp.org/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    skip.ci = true;
  };
}
