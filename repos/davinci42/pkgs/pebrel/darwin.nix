{ undmg }:
{
  nativeBuildInputs = [ undmg ];
  sourceRoot = "Pebrel.app";
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Pebrel.app" "$out/bin"
    cp -R . "$out/Applications/Pebrel.app/"
    ln -s "$out/Applications/Pebrel.app/Contents/MacOS/pebrel" "$out/bin/pebrel"
    ln -s "$out/Applications/Pebrel.app/Contents/MacOS/pebrel-hook" "$out/bin/pebrel-hook"
    runHook postInstall
  '';
}
