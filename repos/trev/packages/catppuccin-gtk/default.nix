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
    "outline"
    "macos"
  ]
  tweaks

  stdenvNoCC.mkDerivation
  (finalAttrs: {
    pname = "catppuccin-gtk-theme";
    version = "unstable-2025-10-23";

    src = fetchFromGitHub {
      owner = "Fausto-Korpsvart";
      repo = "Catppuccin-GTK-Theme";
      rev = "f25d8cf688d8f224f0ce396689ffcf5767eb647e";
      hash = "sha256-W+NGyPnOEKoicJPwnftq26iP7jya1ZKq38lMjx/k9ss=";
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

      name= HOME="$TMPDIR" ./install.sh \
        ${lib.optionalString (themeVariants != [ ]) "--theme " + toString themeVariants} \
        ${lib.optionalString (colorVariants != [ ]) "--color " + toString colorVariants} \
        ${lib.optionalString (sizeVariants != [ ]) "--size " + toString sizeVariants} \
        ${lib.optionalString (tweaks != [ ]) "--tweaks " + toString tweaks} \
        --dest $out/share/themes

      jdupes --quiet --link-soft --recurse $out/share

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--commit"
        finalAttrs.pname
      ];
    };

    meta = {
      description = "A GTK theme based on the colours of Catppuccin";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.unix;
      homepage = "https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme";
    };
  })
