{ fetchurlRhys-T, lib, version, hash }: let
    versionChunks = (builtins.splitVersion version);
    aIndex = (lib.findFirst (x: x.v == "a") null (lib.imap0 (i: v: {inherit i v;}) versionChunks)).i or null;
    alphaNumber = builtins.elemAt versionChunks (aIndex+1);
    url = if aIndex != null then
        "mirror://gryphel/d/minivmac/c/minivmac${alphaNumber}.src.tgz"
    else
        "mirror://gryphel/d/minivmac/minivmac-${version}/minivmac-${version}.src.tgz"
    ;
in fetchurlRhys-T {
    inherit url hash;
}
