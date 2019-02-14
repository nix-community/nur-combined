{ the-powder-toy, fetchFromGitHub, ...}:

the-powder-toy.overrideAttrs (old: rec {
  postPatch =
    let oldPostPatch = if builtins.hasAttr "postPatch" old then old.postPatch else ""; in
      "${oldPostPatch}\nsed -i 's,powder.pref,.powder.pref,g' src/client/Client.cpp";
})
