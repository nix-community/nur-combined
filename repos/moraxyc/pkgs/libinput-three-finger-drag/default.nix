{
  lib,
  rustPlatform,
  libinput,
  xdotool,
  makeWrapper,
  sources,
}:

rustPlatform.buildRustPackage {
  pname = "libinput-three-finger-drag";

  inherit (sources.libinput-three-finger-drag) version src;

  cargoHash = "sha256-6inwT2ume6n+jBEJyiNcscC0U0QkbVgX7EMH3SXvkqc=";

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ xdotool ];

  postFixup = ''
    wrapProgram "$out/bin/libinput-three-finger-drag" \
      --prefix PATH : "${lib.makeBinPath [ libinput ]}"
  '';

  meta = {
    description = "Three-finger-drag support for libinput.";
    homepage = "https://github.com/marsqing/libinput-three-finger-drag";
    license = with lib.licenses; [ mit ];
    mainProgram = "libinput-three-finger-drag";
    platforms = lib.platforms.linux;
  };
}
