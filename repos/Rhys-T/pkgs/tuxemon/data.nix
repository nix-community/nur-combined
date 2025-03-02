{lib, stdenvNoCC, unwrapped, dataHash}: let
    hash = if dataHash == null then lib.fakeHash else dataHash;
    hashAlgo = builtins.head (lib.strings.splitString "-" hash);
in stdenvNoCC.mkDerivation {
    pname = "tuxemon-data";
    inherit (unwrapped) version src;
    dontBuild = true;
    installPhase = ''
        mkdir -p "$out"/share/tuxemon
        cp -r mods "$out"/share/tuxemon/mods
    '';
    outputHash = hash;
    outputHashAlgo = hashAlgo;
    outputHashMode = "recursive";
}
