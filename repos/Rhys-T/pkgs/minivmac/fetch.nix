{ fetchurl, lib, version, hash }: let
    versionChunks = (builtins.splitVersion version);
    aIndex = (lib.findFirst (x: x.v == "a") null (lib.imap0 (i: v: {inherit i v;}) versionChunks)).i or null;
    alphaNumber = builtins.elemAt versionChunks (aIndex+1);
    url = if aIndex != null then
        "https://www.gryphel.com/d/minivmac/c/minivmac${alphaNumber}.src.tgz"
    else
        "https://www.gryphel.com/d/minivmac/minivmac-${version}/minivmac-${version}.src.tgz"
    ;
in fetchurl {
    inherit url hash;
}
