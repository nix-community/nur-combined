{lib, stdenvNoCC, unwrapped, dataHash, _pos}: let
    hash = if dataHash == null then lib.fakeHash else dataHash;
    hashAlgo = builtins.head (lib.strings.splitString "-" hash);
in stdenvNoCC.mkDerivation {
    pname = "tuxemon-data";
    inherit (unwrapped) version src;
    dontBuild = true;
    installPhase = ''
        runHook preInstall
        mkdir -p "$out"/share/tuxemon
        cp -r mods "$out"/share/tuxemon/mods
        runHook postInstall
    '';
    outputHash = hash;
    outputHashAlgo = hashAlgo;
    outputHashMode = "recursive";
    pos = _pos;
}
