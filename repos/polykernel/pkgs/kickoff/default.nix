{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  fontconfig,
  freetype,
  libxkbcommon,
  wayland,
}:

let
  rpathLibs = [
    fontconfig
    freetype
    libxkbcommon
    wayland
  ];
in

rustPlatform.buildRustPackage rec {
  pname = "kickoff";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "j0ru";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-WUDbb/GLABhqE93O6bm19Y+r0kSMEJrvduw68Igub44=";
  };

  cargoHash = "sha256-nhUC9PSKAbNEK5e4WRx3dgYI0rJP5XSWcW6M5E0Ihv4=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = rpathLibs;

  postInstall = ''
    # Strip executable and set RPATH
    # Stolen from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/applications/terminal-emulators/alacritty>
    strip -s $out/bin/kickoff
    patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $out/bin/kickoff
  '';

  dontPatchELF = true;

  meta = with lib; {
    description = "Minimalistic program launcher heavily inspired by rofi.";
    homepage = "https://github.com/j0ru/kickoff";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
