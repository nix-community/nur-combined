{
  stdenv,
  sable-next-unwrapped,
  conf ? { },
}:

stdenv.mkDerivation {
  pname = "sable-next";
  inherit (sable-next-unwrapped) version meta;

  passthru = {
    unwrapped = sable-next-unwrapped;
    inherit conf;
  };

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    ln -s ${sable-next-unwrapped}/* $out
    rm $out/config.json
    cp ${builtins.toFile "sable-config.json" (builtins.toJSON conf)} $out/config.json
  '';
}
