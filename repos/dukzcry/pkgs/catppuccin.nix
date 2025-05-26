let
  validThemes = [ "i3" "mako" "swaylock" ];
in
{ fetchFromGitHub
, lib
, stdenvNoCC
, accent ? "blue"
, variant ? "macchiato"
, themeList ? validThemes
}:
let
  pname = "catppuccin";

  validAccents = [ "rosewater" "flamingo" "pink" "mauve" "red" "maroon" "peach" "yellow" "green" "teal" "sky" "sapphire" "blue" "lavender" ];
  validVariants = [ "latte" "frappe" "macchiato" "mocha" ];

  selectedSources = map (themeName: builtins.getAttr themeName sources) themeList;
  sources = {
    i3 = fetchFromGitHub {
      name = "i3";
      owner = "catppuccin";
      repo = "i3";
      rev = "v1.0.1";
      hash = "sha256-91GsedHF6xM1jmutZX/xdNtGFDrGerRSaRVh29CXt8U=";
    };
    mako = fetchFromGitHub {
      name = "mako";
      owner = "catppuccin";
      repo = "mako";
      rev = "92844f144e72f2dc8727879ec141ffdacf3ff6a1";
      hash = "sha256-jgiZ+CrM4DX2nZR5BjjD9/Rk5CGGUy3gq9CCvYzp5Vs=";
    };
    swaylock = fetchFromGitHub {
      name = "swaylock";
      owner = "catppuccin";
      repo = "swaylock";
      rev = "77246bbbbf8926bdb8962cffab6616bc2b9e8a06";
      hash = "sha256-AKiOeV9ggvsreC/lq2qXytUsR+x66Q0kpN2F4/Oh2Ao=";
    };
  };
in
lib.checkListOfEnum "${pname}: variant" validVariants [ variant ]
lib.checkListOfEnum "${pname}: accent" validAccents [ accent ]
lib.checkListOfEnum "${pname}: themes" validThemes themeList

stdenvNoCC.mkDerivation {
  inherit pname;
  version = "unstable-2025-05-26";

  srcs = selectedSources;

  unpackPhase = ''
    for s in $selectedSources; do
      b=$(basename $s)
      cp $s ''${b#*-}
    done
  '';

  installPhase = ''
    runHook preInstall

    local capitalizedVariant=$(sed 's/^\(.\)/\U\1/' <<< "${variant}")
    local capitalizedAccent=$(sed 's/^\(.\)/\U\1/' <<< "${accent}")

  '' + lib.optionalString (lib.elem "i3" themeList) ''
    mkdir -p $out/i3
    cp "${sources.i3}/themes/catppuccin-${variant}" "$out/i3/"

  '' + lib.optionalString (lib.elem "mako" themeList) ''
    mkdir -p $out/mako
    cp "${sources.mako}/themes/catppuccin-${variant}/catppuccin-${variant}-${accent}" "$out/mako/"

  '' + lib.optionalString (lib.elem "swaylock" themeList) ''
    mkdir -p $out/swaylock
    cp "${sources.swaylock}/themes/${variant}.conf" "$out/swaylock/"

  '' + ''
    runHook postInstall
  '';

  meta = {
    description = "Soothing pastel themes";
    homepage = "https://github.com/catppuccin/catppuccin";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}
