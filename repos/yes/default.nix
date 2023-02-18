{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

{
  archlinux = recurseIntoAttrs (import ./archlinux {
    inherit pkgs rp;
  });
  
  lx-music-desktop = callPackage ./electronAppImage rec {
    pname = "lx-music-desktop";
    version = "2.1.1";
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    src = fetchurl {
      url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
      hash = "sha256-fFpjuE7jRxjcFM+b80rTAMvAOEGIMdI4U0Uzqlo4dZ8=";
    };
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });
}