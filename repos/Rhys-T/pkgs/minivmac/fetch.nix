{ fetchurl, lib, version, hash }: let
    versionChunks = (builtins.splitVersion version);
    aIndex = (lib.findFirst (x: x.v == "a") null (lib.imap0 (i: v: {inherit i v;}) versionChunks)).i or null;
    alphaNumber = builtins.elemAt versionChunks (aIndex+1);
    url = if aIndex != null then
        "mirror://gryphel/d/minivmac/c/minivmac${alphaNumber}.src.tgz"
    else
        "mirror://gryphel/d/minivmac/minivmac-${version}/minivmac-${version}.src.tgz"
    ;
    gryphelMirrors = [
        "https://www.gryphel.com/"
        "http://www.gryphel.org/"
        "https://minivmac.github.io/gryphel-mirror/"
    ];
in (fetchurl {
    inherit url hash;
}).overrideAttrs (old: {
    postHook = (if old.postHook or null != null then old.postHook else "") + ''
        gryphel=${lib.escapeShellArg (builtins.concatStringsSep " " gryphelMirrors)}
    '';
})
