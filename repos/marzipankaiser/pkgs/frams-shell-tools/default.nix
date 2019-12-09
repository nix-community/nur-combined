{ pkgs ? import <nixpkgs> {}
, stdenv ? pkgs.stdenv
, fetchurl ? pkgs.lib.fetchurl
, ...
}:
stdenv.mkDerivation {
      name = "frams-shell-tools";
      src = fetchurl {
          url = "https://fex.belwue.de/sw/share/fstools-0.0.tar";
          sha256 = "1m7q8n8m2q2sryzkz4ylp80hnwwmyw61pzaqi1h0yw60dcrjgwsf";
      };
      buildInputs = [pkgs.perl];
      dontBuild = true;
      installPhase = ''
        mkdir -p $out/bin
        cp -r bin $out/

        mkdir -p $out/share/man
        cp -r man $out/share/

        mkdir -p $out/share/doc
        cp -r doc $out/share/
      '';
      meta = {
        description = "Perl shell tools by framstag@rus.uni-stuttgart.de, e.g. fexsend/fexget";
        homepage = "https://fex.belwue.de/fstools/";
        license = stdenv.lib.licenses.artistic1;
      };
}
