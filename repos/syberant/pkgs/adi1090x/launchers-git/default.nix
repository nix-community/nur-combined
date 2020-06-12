# Basically a reimplementation in nix of https://github.com/adi1090x/rofi/blob/master/launchers-git/launcher.sh

{
  stdenv, fetchFromGitHub, rofi-unwrapped-git, writeScript,
  source-rofi ? import ../source-rofi.nix { inherit fetchFromGitHub; },
  theme ? "screen",
}:

# TODO: remove impurity on fonts
# TODO: get blur working (compton tryone)

# Check if theme exists
assert builtins.elem theme [
  "blurry"
  "blurry_full"
  "kde_simplemenu"
  "kde_krunner"
  "launchpad"
  "gnome_do"
  "slingshot"
  "appdrawer"
  "appfolder"
  "column"
  "row"
  "row_center"
  "screen"
  "row_dock"
  "row_dropdown"
];

let
  repo = stdenv.mkDerivation {
    name = "source-rofi-adi1090x";
    src = "${source-rofi}";

    installPhase = ''
      mkdir $out
      # Only copy launchers-git directory because we don't use the rest
      cp -r launchers-git $out
    '';
  };
  rofi = "${rofi-unwrapped-git}/bin/rofi";
in writeScript "launchers-git" ''
  ${rofi} -no-lazy-grab -show drun -theme ${repo}/launchers-git/${theme}.rasi
''

