{
  fetchFromGitHub,
  stdenv,
  lib,
  # Available: astronaut black_hole cyberpunk hyprland_kath jake_the_dog japanese_aesthetic pixel_sakura pixel_sakura_static post-apocalyptic_hacker purple_leaves
  theme,
}: let
  src = fetchFromGitHub {
    owner = "Keyitdev";
    repo = "sddm-astronaut-theme";
    rev = "c10bd950544036c7418e0f34cbf1b597dae2b72f";
    hash = "sha256-ITufiMTnSX9cg83mlmuufNXxG1dp9OKG90VBZdDeMxw=";
  };

  installPath = "$out/share/sddm/themes/sddm-astronaut-theme";
  themePath = "Themes/${theme}.conf";
in
  lib.warnIfNot (builtins.pathExists "${src}/${themePath}") ''
    [sddm-astronaut-theme] Configuration file does not exist at ${themePath} - configuration may not work as expected
  ''
  stdenv.mkDerivation {
    pname = "sddm-astronaut-theme";
    version = "git";
    inherit src;

    installPhase =
      ''
        mkdir -p ${installPath}
        cp -r * ${installPath}/

        # remove meta files
        rm ${installPath}/{README.md,setup.sh}
      ''
      + lib.optionalString (theme != null) ''
        sed -i 's|^ConfigFile=.*$|ConfigFile=${themePath}|' ${installPath}/metadata.desktop
      '';
  }
