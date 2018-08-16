{ stdenv, lib, pkgs, fetchFromGitHub, ... }:
stdenv.mkDerivation rec {
  name = "pkg2zip-2017-12-01";
  rev = "fccad26";

  src = fetchFromGitHub {
    owner = "mmozeiko";
    repo = "pkg2zip";
    inherit rev;
    sha256 = "1sq9yx5cbllmc0yyxhvb6c0yq1mkd1mn8njgkkgxz8alw9zwlarp";
  };

  installPhase = ''
    install -m755 -D pkg2zip $out/bin/pkg2zip

    install -m755 -D rif2zrif.py $out/bin/rif2zrif
    install -m755 -D zrif2rif.py $out/bin/zrif2rif
  '';

  buildInputs = with pkgs;[
    python3
  ];

  meta = {
    homepage = https://github.com/St4rk/PkgDecrypt;
    description = "St4rk's Vita pkg decrypter";
    license = lib.licenses.gpl2;
  };
}
