{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  cutefish-toolkit,
  icu,
  libpng,
  pipewire,
  systemd,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-framework";
  version = cu.version "2026-10-24";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-framework";
    rev = "d6588f353ea2416e2f6849dab66233bd6be874e4";
    hash = "sha256-e/QLZwqfpA4DShyiupxjILyurunStk8AoR97sHKrDgY=";
  };

  postPatch = ''
    substituteInPlace clients/networkmanager/vpn_utils.cpp \
      --replace-fail '{"/etc/NetworkManager/VPN", "/usr/lib/NetworkManager/VPN"}' \
        '{"/etc/NetworkManager/VPN", "/run/current-system/sw/lib/NetworkManager/VPN", "/usr/lib/NetworkManager/VPN"}'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    libpng
    pipewire
    systemd
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "System-service clients and file operations for the Cutefish desktop";
    license = lib.licenses.bsd3;
  };
}
