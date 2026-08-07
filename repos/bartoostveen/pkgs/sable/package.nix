{
  stdenv,
  sable-unwrapped,
  conf ? { },
}:

stdenv.mkDerivation {
  pname = "sable";
  inherit (sable-unwrapped) version meta;

  passthru = {
    unwrapped = sable-unwrapped;
    inherit conf;
  };

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    ln -s ${sable-unwrapped}/* $out
    rm $out/config.json
    cp ${builtins.toFile "sable-config.json" (builtins.toJSON conf)} $out/config.json
  '';
}
