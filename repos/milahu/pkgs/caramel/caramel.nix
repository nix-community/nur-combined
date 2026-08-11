# https://caramel.run/manual/contrib/building.html
# /home/user/src/nixpkgs/pkgs/tools/typesetting/satysfi/default.nix

{ lib, stdenv, fetchFromGitHub, ruby, dune_2, ocamlPackages
, ipaexfont, junicode, lmodern, lmmath
}:
let
/*
  camlpdf = ocamlPackages.camlpdf.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "gfngfn";
      repo = "camlpdf";
      rev = "v2.3.1+satysfi";
      sha256 = "1s8wcqdkl1alvfcj67lhn3qdz8ikvd1v64f4q6bi4c0qj9lmp30k";
    };
  });
  otfm = ocamlPackages.otfm.overrideAttrs (o: {
    src = fetchFromGitHub {
      owner = "gfngfn";
      repo = "otfm";
      rev = "v0.3.7+satysfi";
      sha256 = "0y8s0ij1vp1s4h5y1hn3ns76fzki2ba5ysqdib33akdav9krbj8p";
    };
    propagatedBuildInputs = o.propagatedBuildInputs ++ [ ocamlPackages.result ];
  });
  yojson-with-position = ocamlPackages.buildDunePackage {
    pname = "yojson-with-position";
    version = "1.4.2";
    src = fetchFromGitHub {
      owner = "gfngfn";
      repo = "yojson-with-position";
      rev = "v1.4.2+satysfi";
      sha256 = "17s5xrnpim54d1apy972b5l08bph4c0m5kzbndk600fl0vnlirnl";
    };
    useDune2 = true;
    nativeBuildInputs = [ ocamlPackages.cppo ];
    propagatedBuildInputs = [ ocamlPackages.biniou ];
    inherit (ocamlPackages.yojson) meta;
  };
*/
in
  #ocamlPackages.buildDunePackage rec {
  stdenv.mkDerivation rec {
    pname = "caramel";
    version = "0.1.1";
    src = fetchFromGitHub {
      owner = "AbstractMachinesLab";
      repo = "caramel";
      rev = "v${version}";
      sha256 = "sha256-WnKH29+MO0mLjqsPWOENq2kAkzEntSy+/yEDKywTM4g=";
      #fetchSubmodules = true;
    };

    nativeBuildInputs = [
      #ruby
      dune_2
      ocamlPackages.ocaml
    ];

/*
    preConfigure = ''
      substituteInPlace src/frontend/main.ml --replace \
      '/usr/local/share/satysfi"; "/usr/share/satysfi' \
      $out/share/satysfi
    '';

    DUNE_PROFILE = "release";

    buildInputs = [ camlpdf otfm yojson-with-position ] ++ (with ocamlPackages; [
      ocaml findlib menhir menhirLib
      batteries camlimages core_kernel ppx_deriving uutf omd cppo re
    ]);

    installPhase = ''
      cp -r ${ipaexfont}/share/fonts/opentype/* lib-satysfi/dist/fonts/
      cp -r ${junicode}/share/fonts/junicode-ttf/* lib-satysfi/dist/fonts/
      cp -r ${lmodern}/share/fonts/opentype/public/lm/* lib-satysfi/dist/fonts/
      cp -r ${lmmath}/share/fonts/opentype/latinmodern-math.otf lib-satysfi/dist/fonts/
      make install PREFIX=$out LIBDIR=$out/share/satysfi
      mkdir -p $out/share/satysfi/
      cp -r lib-satysfi/dist/ $out/share/satysfi/
    '';
*/

    meta = with lib; {
      homepage = "https://github.com/AbstractMachinesLab/caramel";
      description = "OCaml to Erlang VM (BEAM) compiler";
#      changelog = "https://github.com/gfngfn/SATySFi/blob/v${version}/CHANGELOG.md";
      license = licenses.asl20;
      #maintainers = [ maintainers.mt-caret maintainers.marsam ];
      platforms = platforms.all;
    };
  }
