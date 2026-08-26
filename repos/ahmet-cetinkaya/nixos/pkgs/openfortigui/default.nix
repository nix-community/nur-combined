{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6,
  qt6Packages,
  openssl,
  ppp,
}:
stdenv.mkDerivation rec {
  pname = "openfortigui";
  version = "0.9.13";

  src = fetchFromGitHub {
    owner = "theinvisible";
    repo = "openfortigui";
    rev = "v${version}-1";
    hash = "sha256-ZghNurrk5VPyp3DHhOEssU5+18uuKmXgJkEp3TCJp/I=";
    fetchSubmodules = true;
  };

  buildInputs = [
    qt6.qtbase
    openssl
    qt6Packages.qtkeychain
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  postPatch = ''
    # Update pppd path to Nix store path
    substituteInPlace openfortigui/CMakeLists.txt \
      --replace-fail '/usr/sbin/pppd' '${ppp}/bin/pppd'

    # Sudoers fragments belong in /etc/sudoers.d, not the Nix store; the
    # sandboxed build can't write there anyway. Drop the install() stanza.
    sed -i '/install(FILES sudo\/openfortigui/,/PERMISSIONS OWNER_READ GROUP_READ)/d' \
      openfortigui/CMakeLists.txt
  '';

  meta = with lib; {
    description = "GUI for openfortivpn (FortiGate VPN client)";
    homepage = "https://github.com/theinvisible/openfortigui";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
  };
}
