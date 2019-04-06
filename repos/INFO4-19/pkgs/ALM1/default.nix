{ stdenv, fetchurl }:

let
  lustre = stdenv.mkDerivation rec {
      name = "lustreV4";

      src = fetchurl {
        url = http://www-verimag.imag.fr/DIST-TOOLS/SYNCHRONE/lustre-v4/distrib/linux64/lustre-v4-III-dc-linux64.tgz;
        sha256 = "0ynk5mm68ywz6w3qncs2klyz6l9k97yk2b4bpkwk3k3zxhvxbgqr";
      };

      installPhase = ''
        mkdir -p $out/bin
        cd bin
        cp * $out/bin/
        chmod +x $out/bin/*
      '';

    };
in
stdenv.mkDerivation rec {
  name = "ALM1";
  shellHook = ''
      echo -e "\e[32m=============================================\e[0m"
      echo -e "\e[32m=== Welcome to ALM1 environment ===\e[0m"
      echo -e "\e[32m=============================================\e[0m"
    '';

  buildInputs = [ lustre ];
}
