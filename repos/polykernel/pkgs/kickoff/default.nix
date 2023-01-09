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
  version = "v0.6.0";

  src = fetchFromGitHub {
    owner = "j0ru";
    repo = pname;
    rev = version;
    sha256 = "sha256-CY0D6pAuAlCiO7f5MitjLfti+3JnFAguJYlaTSq6rGI=";
  };

  cargoHash = "sha256-CMneBDn0hB9edqEahRjz4jYtJeKa6Gv3PUWW0LS5Mes=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fontconfig
  ];

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
