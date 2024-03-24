{ lib, stdenv
, fetchFromGitHub
, gtk4-layer-shell
, gtkmm4
, pkg-config
, pulseaudio
, wrapGAppsHook4
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sysvol";
  version = "0-unstable-2024-02-08";

  src = fetchFromGitHub {
    owner = "AmirDahan";
    repo = "sysvol";
    rev = "b8a15ca2e52922bceab3f48c5630149674da57e9";
    hash = "sha256-BaefSRnn6ww3Ut+3ouXKoI/8/vmcPh/QV6dEETr3tog=";
  };
  postPatch = let
    # i don't know how else to escape this
    var = v: lib.concatStrings [ "$" "{" v "}" ];
  in ''
    substituteInPlace Makefile \
      --replace-fail 'pkg-config' '${var "PKG_CONFIG"}' \
      --replace-fail 'g++' '${var "CXX"}' \
      --replace-fail 'strip sysvol' ""
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4  #< to plumb `GDK_PIXBUF_MODULE_FILE` through, and get not-blurry icons
  ];
  buildInputs = [
    gtk4-layer-shell
    gtkmm4
    pulseaudio
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 sysvol $out/bin/sysvol
  '';

  meta = {
    description = "A basic GTK4 volume indicator";
    inherit (finalAttrs.src.meta) homepage;
    mainProgram = "sysvol";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
