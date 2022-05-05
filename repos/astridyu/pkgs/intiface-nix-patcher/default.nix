{ stdenv, lib, writeShellScriptBin, patchelf, openssl, dbus, udev }:

let
  libPath = lib.makeLibraryPath [ openssl dbus udev ];
in
  writeShellScriptBin "intiface-nix-patcher" ''
    executable=''${1:-~/.config/IntifaceDesktop/engine/IntifaceCLI}
    echo "Patching $executable"
    ${patchelf}/bin/patchelf --set-interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}:$src:\$ORIGIN" \
      $executable
  ''

