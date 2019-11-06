{ stdenv, lib, pkgs, fetchFromGitHub, ... }:
stdenv.mkDerivation rec {
  name = "pkg2zip-2018-06-15";
  rev = "9222c4e00235dfe7914e9db0cc352da07e63d9f9";

  src = fetchFromGitHub {
    owner = "mmozeiko";
    repo = "pkg2zip";
    inherit rev;
    sha256 = "1zz3vi12c2c4d48vvvkdl66fx5mdszcnv7lwwlgi4b8lfn1gvkr9";
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
