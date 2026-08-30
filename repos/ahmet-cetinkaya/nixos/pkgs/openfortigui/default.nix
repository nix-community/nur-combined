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
}: let
  openfortivpnSrc = fetchFromGitHub {
    owner = "adrienverge";
    repo = "openfortivpn";
    rev = "a40a2d588733d48534eb78cd17b90142e5ba039b";
    hash = "sha256-zJSEBfhb2dFEOW/sJyB7xFLGGUQLjkz20V80L0ew7J8=";
  };
in
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
      rm -rf openfortigui/openfortivpn
      cp -r ${openfortivpnSrc} openfortigui/openfortivpn

      # Update pppd path to Nix store path
      substituteInPlace openfortigui/CMakeLists.txt \
        --replace-fail '/usr/sbin/pppd' '${ppp}/bin/pppd'

      # Sudoers fragments belong in /etc/sudoers.d, not the Nix store; the
      # sandboxed build can't write there anyway. Drop the install() stanza.
      sed -i '/install(FILES sudo\/openfortigui/,/PERMISSIONS OWNER_READ GROUP_READ)/d' \
        openfortigui/CMakeLists.txt

      # Upstream still hardcodes the executable's FHS path.
      substituteInPlace openfortigui/app-entry/openfortigui.desktop \
        --replace-fail '/usr/bin/openfortigui' 'openfortigui'
    '';

    meta = with lib; {
      description = "GUI for openfortivpn (FortiGate VPN client)";
      homepage = "https://github.com/theinvisible/openfortigui";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      maintainers = ["Ahmet Çetinkaya <contact@ahmetcetinkaya.me>"];
    };
  }
