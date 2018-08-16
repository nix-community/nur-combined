{ stdenv, lib, pkgs, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "cue2pops";
  version = "2";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "makefu";
    repo = "cue2pops-linux";
    rev = "541863a";
    sha256 = "05w84726g3k33rz0wwb9v77g7xh4cnhy9sxlpilf775nli9bynrk";
  };

  installPhase = ''
    install -Dm755 $pname $out/bin/$pname
  '';

  meta = {
    homepage = http://users.eastlink.ca/~doiron/bin2iso/ ;
    description = "converts bin+cue to iso";
    license = lib.licenses.gpl3;
  };
}
