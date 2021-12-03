{ runCommand
, makeWrapper
, electron
}:

runCommand "electron-wayland-${electron.version}"
  {
    nativeBuildInputs = [ makeWrapper ];
    passthru.unwrapped = electron;
    inherit (electron) meta;
  }
  ''
    mkdir -p "$out"
    ln -s ${electron}/* "$out"

    rm "$out/bin"; mkdir "$out/bin"
    ln -s ${electron}/bin/* "$out/bin"

    rm "$out/bin/electron"
    makeWrapper ${electron}/bin/electron "$out/bin/electron" \
      --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'
  ''
