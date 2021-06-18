{ pkgs, ... }@inputs:

pkgs.hello.overrideAttrs (oldAttrs: rec {
  __contentAddressed = true;
  postPatch = ''
    sed -i -e 's/Hello, world!/Hello, NUR from ethancedwards8/' src/hello.c
  '';
})
