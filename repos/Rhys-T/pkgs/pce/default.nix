{callPackage, requireFile, fetchpatch, ...}@args: let
    thruArgs = removeAttrs args ["callPackage" "requireFile" "fetchpatch"];
in callPackage ./generic.nix (thruArgs // rec {
    version = "0.2.2";
    includesUnfreeROMs = true;
    src = rec {
        name = "pce-${version}.tar.gz";
        url = http://www.hampa.ch/pub/pce + "/pce-${version}.tar.gz";
        hashWithROMs = "sha256-qMBWD8vwzBVMj1ASGG89OVKv29FEtBkSTAmlb5uquZk=";
        hashWithoutROMs = "sha256-z65BS+arlhem1Z0CN9W5S4p4M3onQNqX804kFeRonME=";
    };
    patches = [(fetchpatch {
        name = "0001-68000-Add-a-missing-extern-declaration.patch";
        url = http://git.hampa.ch/pce.git/patch/f9ebfc33107a10436506861601b162df98ca743e;
        # Fix the changes to the copyright header comment,
        # because otherwise the patch doesn't apply correctly.
        decode = "sed 's/(C) 2005-2018/(C) 2005-2009/'";
        hash = "sha256-T3Fc4yHANjpE1Peh7Fipuk5rqFrSCpGK1f5HWyz/Q5g=";
    })];
    supportsSDL2 = false;
})
