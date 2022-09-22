{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, fontconfig
, freetype
, libxkbcommon
, wayland
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
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "j0ru";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-dfbstCnuaUaA8Nk140kGalyD6IvF5ECVgGSBatKXUZ4=";
  };

  cargoHash = "sha256-wJbE1TJ8/UkSJ0DcgX/4zKePohAUaTVM+krOxXH2sWI=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ fontconfig ];

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
