# Packaged by SamLukeYes, original file is licensed under the MIT license.
# https://github.com/SamLukeYes/nixos/blob/master/pkgs/shijima-qt/package.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  cmake,
  libarchive,
  pkg-config,
  qt6,
  xz,
  zip,
  zlib,
}:

stdenv.mkDerivation (final: {
  pname = "shijima-qt";
  version = "0.1.0";

  # https://github.com/NixOS/nixpkgs/issues/195117#issuecomment-1410398050
  src =
    (fetchFromGitHub {
      owner = "pixelomer";
      repo = "Shijima-Qt";
      rev = "v${final.version}";
      hash = "sha256-/oyFKkzhEW1+VbJyEmUw6s1m83edQ1lNYDlF5gQR9s4=";
      fetchSubmodules = true;
    }).overrideAttrs
      (oldAttrs: {
        env = oldAttrs.env or { } // {
          GIT_CONFIG_COUNT = 1;
          GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
          GIT_CONFIG_VALUE_0 = "git@github.com:";
        };
      });

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    zip
  ];

  postPatch = ''
    patchShebangs --build .
  '';

  dontUseCmakeConfigure = true;

  makeFlags = [
    "CONFIG=release"
    "CMAKEFLAGS=-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  hardeningDisable = [ "fortify" ];

  buildInputs = [
    bzip2
    libarchive
    qt6.qtbase
    qt6.qtmultimedia
    xz
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp publish/Linux/release/shijima-qt $out/bin

    mkdir -p $out/lib
    cp publish/Linux/release/lib* $out/lib

    mkdir -p $out/share/applications
    cp com.pixelomer.ShijimaQt.desktop $out/share/applications

    mkdir -p $out/share/pixmaps
    cp com.pixelomer.ShijimaQt.png $out/share/pixmaps

    mkdir -p $out/share/gnome-shell/extensions
    cp -r Platform/Linux/gnome_script $out/share/gnome-shell/extensions/shijima-helper@pixelomer.github.io

    runHook postInstall
  '';

  preFixup = ''
    patchelf --shrink-rpath \
      --allowed-rpath-prefixes /nix/store \
      --add-rpath $out/lib \
      $out/bin/shijima-qt
  '';

  meta = {
    description = "Shimeji desktop pet runner";
    homepage = "https://github.com/pixelomer/Shijima-Qt";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ samlukeyes123 ];
    mainProgram = "shijima-qt";
    platforms = lib.platforms.linux;
  };
})
