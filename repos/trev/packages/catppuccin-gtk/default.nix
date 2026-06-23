{
  fetchFromGitHub,
  gtk-engine-murrine,
  jdupes,
  lib,
  nix-update-script,
  sassc,
  stdenvNoCC,
  themeVariants ? [ ], # default: blue
  colorVariants ? [ ], # default: all
  sizeVariants ? [ ], # default: standard
  tweaks ? [ ],
}:
let
  shellTweaks = builtins.filter (tweak: tweak == "float") tweaks;
  gtkTweaks = map (tweak: if tweak == "outline" then "border" else tweak) (
    builtins.filter (tweak: tweak != "float") tweaks
  );
in

lib.checkListOfEnum "catppuccin-gtk-theme: theme variants"
  [
    "default"
    "blue"
    "flamingo"
    "green"
    "grey"
    "lavender"
    "maroon"
    "mauve"
    "peach"
    "pink"
    "red"
    "rosewater"
    "sapphire"
    "sky"
    "teal"
    "yellow"
    "all"
  ]
  themeVariants

  lib.checkListOfEnum
  "catppuccin-gtk-theme: color variants"
  [ "light" "dark" ]
  colorVariants

  lib.checkListOfEnum
  "catppuccin-gtk-theme: size variants"
  [ "standard" "compact" ]
  sizeVariants

  lib.checkListOfEnum
  "catppuccin-gtk-theme: tweaks"
  [
    "frappe"
    "macchiato"
    "black"
    "float"
    "border"
    "outline"
    "macos"
  ]
  tweaks

  stdenvNoCC.mkDerivation
  (finalAttrs: {
    pname = "catppuccin-gtk";
    version = "1.0.1-unstable-2026-06-22";

    src = fetchFromGitHub {
      owner = "Fausto-Korpsvart";
      repo = "Catppuccin-GTK-Theme";
      rev = "0a0bf27831e2a7e941cd77ad2948b31bf7556edd";
      hash = "sha256-wS5Pt/Ao4iFY9Nc5ceDUHTVB5pZLyIoaPUSavja3pHw=";
    };

    sourceRoot = "${finalAttrs.src.name}/themes";

    nativeBuildInputs = [
      jdupes
      sassc
    ];

    propagatedUserEnvPkgs = [
      gtk-engine-murrine
    ];

    postPatch = ''
      patchShebangs install.sh
    '';

    installPhase = ''
      runHook preInstall

      name= BATCH_MODE=true HOME="$TMPDIR" ./install.sh \
        ${lib.optionalString (themeVariants != [ ]) "--theme " + toString themeVariants} \
        ${lib.optionalString (colorVariants != [ ]) "--color " + toString colorVariants} \
        ${lib.optionalString (sizeVariants != [ ]) "--size " + toString sizeVariants} \
        ${lib.optionalString (gtkTweaks != [ ]) "--tweaks " + toString gtkTweaks} \
        ${lib.optionalString (shellTweaks != [ ]) "--shell " + toString shellTweaks} \
        --dest $out/share/themes

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--commit"
        "--version=branch=main"
        finalAttrs.pname
      ];
    };

    meta = {
      description = "A GTK theme based on the colours of Catppuccin";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
      homepage = "https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme";
    };
  })
