{ stdenv, lib, fetchFromGitHub, pkgs, ... }:

let
  commonMeta = rec {
    name = "orgmk";
    version = "2022-01-20";
  };
  myEmacs = pkgs.emacs28NativeComp;
  emacsWithPackages = (pkgs.emacsPackagesFor myEmacs).emacsWithPackages;
in stdenv.mkDerivation {
  name = "${commonMeta.name}_${commonMeta.version}";

  buildInputs = [
    (emacsWithPackages (epkgs: (with epkgs.melpaPackages; [
      #org-plus-contrib
      htmlize
      ox-gfm
    ])))
  ];
  patches = [ ./make.patch ];
  preBuild = ''
    emacs --batch -f package-initialize
    mkdir -p $out/bin
    mkdir -p $out/share/orgmk
  '';
  src = fetchFromGitHub {
    owner = "fniessen";
    repo = "orgmk";
    rev = "ba72326";
    sha256 = "+2ldIlT7OFbYm+DWaP44eaiCacfQddjPRd1xasvE7/I=";
  };
  meta = {
    homepage = "https://github.com/fniessen/orgmk";
    platforms = [ "x86_64-linux" ];
    license = with lib.licenses; [ gpl3 ];
    maintainers = [ lib.maintainers.ProducerMatt ];
    broken = true; #FIXME
  };
}
