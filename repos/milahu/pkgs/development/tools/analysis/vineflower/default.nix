{
  lib,
  stdenv,
  #fetchFromGitHub,
  fetchurl,
  makeWrapper,
  jre,
}:

stdenv.mkDerivation rec {
  pname = "vineflower";
  version = "1.10.1";

  # TODO source build?
  # example: nixpkgs/pkgs/tools/security/jd-gui/default.nix
  /*
  src = fetchFromGitHub {
    owner = "Vineflower";
    repo = "vineflower";
    rev = version;
    hash = "sha256-TOexLSA0r3weIH96P+LYm0xV+vqWh7kQF/44T9CQdhQ=";
  };
  */

  # binary build
  src = fetchurl {
    url = "https://github.com/Vineflower/vineflower/releases/download/${version}/vineflower-${version}.jar";
    sha256 = "sha256-ubII5QeTtkZXprYpIGdSZhP1Sd50BfkkNiSwL0J25Ak=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildCommand = ''
    jar=$out/share/java/vineflower-${version}.jar
    install -Dm444 $src $jar
    makeWrapper ${jre}/bin/java $out/bin/vineflower --add-flags "-jar $jar"
  '';

  meta = {
    description = "Modern Java decompiler aiming to be as accurate as possible, with an emphasis on output quality. Fork of the Fernflower decompiler";
    homepage = "https://github.com/Vineflower/vineflower";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "vineflower";
    platforms = lib.platforms.all;
  };
}
