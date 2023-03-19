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
  version = "v0.7.0";

  src = fetchFromGitHub {
    owner = "j0ru";
    repo = pname;
    rev = version;
    sha256 = "sha256-AolJXFolMEwoK3AtC93naphZetytzRl1yI10SP9Rnzo=";
  };

  cargoHash = "sha256-OEFCR/2zSVZhZqAp6n48UyIwplRXxKb9HENsVaLIKkM=";

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
