{ stdenv, lib, config, fetchFromGitHub, pkgs, fetchpatch, ... }:

stdenv.mkDerivation rec {
  pname = "cpufetch";
  version = "0.97";

  src = fetchFromGitHub {
    owner = "Dr-Noob";
    repo = pname;
    rev = "v${version}";
    sha256 = "1rzq7zsh7krpf3fp22mzxzmi3a1xq37a222hsfc6jzf7nvsvnxff";
  };

  outputs = [ "out" "man" ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "Simple yet fancy CPU architecture fetching tool";
    homepage = "https://github.com/Dr-Noob/cpufetch";

    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
