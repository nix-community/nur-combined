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

  cargoHash = "sha256-0a4egvNTGup/HhsF88G7PLTm7BfUKEDLTh3IPsnZ1zY=";

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
