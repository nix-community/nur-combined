{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  gettext,
}:
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-valent";
  version = "unstable-2023-02-25";

  src = fetchFromGitHub {
    owner = "andyholmes";
    repo = "gnome-shell-extension-valent";
    rev = "c82e682e00b627772acd1af762a86903a12deedc";
    sha256 = "sha256-2jpgAnA1HlQJtxNcKOji1Ie+A1Ngv6NvMuSVJX9xsd4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    gettext
  ];

  meta = with lib; {
    description = "GNOME Shell integration for Valent";
    homepage = "https://github.com/andyholmes/gnome-shell-extension-valent";
    changelog = "https://github.com/andyholmes/gnome-shell-extension-valent/blob/${src.rev}/CHANGELOG.md";
    license = with licenses; [gpl3Plus cc0];
  };
}
