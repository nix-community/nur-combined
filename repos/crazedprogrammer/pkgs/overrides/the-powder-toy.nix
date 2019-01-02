{ the-powder-toy, fetchFromGitHub, ...}:

the-powder-toy.overrideAttrs (old: rec {
  postPatch = "${old.postPatch}\nsed -i 's,powder.pref,.powder.pref,g' src/client/Client.cpp";
})
