{ lib
, stdenv
, python3
}:
let
  python = python3.withPackages (py: [ py.requests ]);
in
stdenv.mkDerivation {
  name = "porkbun-ddns";

  src = ./.;
  inherit python;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm0755 $src/porkbun-ddns.py $out/bin/porkbun-ddns
    substituteAllInPlace $out/bin/porkbun-ddns
  '';

  meta = {
    description = "Porkbun dynamic DNS script";
    license = lib.licenses.gpl3;
    platforms = python.meta.platforms;
  };
}
