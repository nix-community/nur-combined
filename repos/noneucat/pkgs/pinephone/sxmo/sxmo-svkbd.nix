{ stdenv, fetchgit, libX11, libXft, libXtst, libXi, libXinerama
, conf ? null, patches ? [], layouts ? ["sxmo"] }:

with stdenv.lib;

stdenv.mkDerivation {
  pname = "sxmo-svkbd";
  version = "1.0.5";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-svkbd";
    rev = "${version}";
    sha256 = "0ymlz35bqmlwdmvghnc2kvjwaqw59j4j3x67lq84yyjscfnkj3w6";
  };

  inherit patches;

  # suckless configuration
  # pkgs/applications/terminal-emulators/st/default.nix
  configFile = optionalString (conf!=null) (writeText "config.def.h" conf);
  postPatch = optionalString (conf!=null) "cp ${configFile} config.def.h"
    + ''
    sed -i "s@CC = cc@CC = $CC@g" config.mk
    sed -i "s@PREFIX ?= /usr/local@PREFIX = $out@g" config.mk
  '';

  buildInputs = [
    libX11
    libXft
    libXtst
    libXi
    libXinerama
  ];

  PREFIX="$out";
  buildPhase = concatMapStringsSep "\n" (layout: "make svkbd-${layout}") layouts;

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-svkbd";
    description = "Svkbd onscreen keyboard for sxmo";
    license = licenses.mit;
    maintainers = [ maintainers.noneucat ];
    platforms = platforms.linux;
  };
}