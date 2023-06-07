# https://github.com/huantianad/nixos-config/blob/main/packages/flatpak-xdg-utils/default.nix
# 
{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, cmake, glib }:

stdenv.mkDerivation rec {
  pname = "flatpak-xdg-utils";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "flatpak";
    repo = "flatpak-xdg-utils";
    rev = version;
    sha256 = "sha256-TqUV8QpBti+86FElCdHXifIS2dsShA/POFUyZwjTHOE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
  ];

  buildInputs = [
    glib
  ];

  meta = with lib; {
    description = "Simple portal-based commandline tools for use inside flatpak sandboxes";
    homepage = "https://github.com/flatpak/flatpak-xdg-utils";
    downloadPage = "https://github.com/flatpak/flatpak-xdg-utils/releases";
    changelog = "https://github.com/flatpak/flatpak-xdg-utils/releases/tag/v${version}";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [];
    platforms = [ "x86_64-linux" ];
  };
}
