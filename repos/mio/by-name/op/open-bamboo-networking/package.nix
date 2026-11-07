# Copyright (c) 2024 Tom Sievers
# SPDX-License-Identifier: MIT
#
# NixOS packaging logic is originally inspired by and adapted from:
# https://codeberg.org/TomSievers/open-bamboo-networking-nixos.git
{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openssl,
  zlib,
  curl,
  uthash,
  mosquitto,
  cjson,
  client ? "bambu_studio", # or "orca_slicer"
  pluginVersion ? "02.05.00.99",
  nix-update-script,
  writeShellApplication,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "open-bamboo-networking";
  version = "2.3.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ClusterM";
    repo = "open-bamboo-networking";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0yrbsZvpeZozAq0baDbInxnmXoOI/8rL8G106PwbfFg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
    zlib
    curl
    uthash
  ];

  cmakeFlags = [
    (lib.cmakeFeature "OBN_VERSION" pluginVersion)
    (lib.cmakeFeature "OBN_CLIENT_TYPE" client)
    (lib.cmakeBool "OBN_RELEASE" true)
    (lib.cmakeBool "OBN_PATCH_CLIENT_CONF" false)
    (lib.cmakeBool "OBN_BUILD_TESTS" false)
    # Prefer a staged Nix install, not ~/.config/BambuStudio
    (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" "${placeholder "out"}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_CJSON" "${cjson.src}")
  ];

  preConfigure = ''
    cp -r ${mosquitto.src} $TMPDIR/source/mosquitto-src
    chmod -R u+w $TMPDIR/source/mosquitto-src

    cmakeFlagsArray+=(
      "-DFETCHCONTENT_SOURCE_DIR_ECLIPSE_MOSQUITTO=$TMPDIR/source/mosquitto-src"
    )
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-open-bamboo-networking";
    text = ''
      export UPDATE_NIX_ATTR_PATH="open-bamboo-networking"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

  meta = {
    changelog = "https://github.com/ClusterM/open-bamboo-networking/releases/tag/v${finalAttrs.version}";
    description = "Open-source Bambu/Orca network plugin replacement";
    homepage = "https://github.com/ClusterM/open-bamboo-networking";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ mio ];
    platforms = lib.platforms.linux;
  };
})
