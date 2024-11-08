{ lib
, stdenvNoCC
, fetchFromGitHub
, gitUpdater
, gnome-themes-extra
, gtk-engine-murrine
, jdupes
, sassc
, themeVariants ? [ ] # default: blue
, colorVariants ? [ ] # default: all
, sizeVariants ? [ ] # default: standard
, tweaks ? [ ]
, roundVariants ? [ ]
}:

let
  pname = "Orchis-gtk";
in
lib.checkListOfEnum "${pname}: theme variants" [ "default" "purple" "pink" "red" "orange" "yellow" "green" "teal" "grey" "all" ]
  themeVariants
  lib.checkListOfEnum "${pname}: color variants" [ "standard" "light" "dark" ]
  colorVariants
  lib.checkListOfEnum "${pname}: size variants" [ "standard" "compact" ]
  sizeVariants
  lib.checkListOfEnum "${pname}: tweaks" [ "compact" "black" "primary" "macos" "submenu" "nord" "dracula" "dock" ]
  tweaks
  lib.checkListOfEnum "${pname}: round" [ "3px" "4px" "5px" "6px" "7px" "8px" "9px" "10px" "11px" "12px" "13px" "14px" "15px" ]
  roundVariants

  stdenvNoCC.mkDerivation
  (finalAttrs: {
    inherit pname;
    version = "2024-11-03";

    src = fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Orchis-theme";
      rev = finalAttrs.version;
      hash = "sha256-K8FiS1AiFMhVaz2Jbr0pudQJGqpwBkQ/4NZdZACtM9Q=";
    };

    nativeBuildInputs = [
      jdupes
      sassc
    ];

    buildInputs = [
      gnome-themes-extra
    ];

    propagatedUserEnvPkgs = [
      gtk-engine-murrine
    ];

    postPatch = ''
      patchShebangs install.sh
    '';

    installPhase = ''
      runHook preInstall

      name= HOME="$TMPDIR" ./install.sh \
        ${lib.optionalString (themeVariants != []) "--theme " + builtins.toString themeVariants} \
        ${lib.optionalString (colorVariants != []) "--color " + builtins.toString colorVariants} \
        ${lib.optionalString (sizeVariants != []) "--size " + builtins.toString sizeVariants} \
        ${lib.optionalString (roundVariants != []) "--round " + builtins.toString roundVariants} \
        ${lib.optionalString (tweaks != []) "--tweaks " + builtins.toString tweaks} \
        --icon nixos \
        --dest $out/share/themes

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    passthru.updateScript = gitUpdater { };

    meta = {
      description = "Material Design gtk theme";
      homepage = "https://github.com/vinceliuice/Orchis-theme";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.unix;
    };
  })
