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
  version = "0-unstable-2024-04-11";

  src = fetchFromGitHub {
    owner = "AmirDahan";
    repo = "sysvol";
    rev = "a26809de285ee194436bc55ef701476765c5b15e";
    hash = "sha256-WiFm5SRQV2up9EBCR9oF0p9F+DQHDQZhxsaUuvpbMw8=";
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
