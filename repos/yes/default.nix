{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs;

let 
  electron_19_1 = electron.overrideAttrs (old: rec {
    version = "19.1.9";
    src = fetchurl {
      url = "${rp}https://github.com/electron/electron/releases/download/v${version}/electron-v${version}-linux-x64.zip";
      hash = "sha256-/TIGdfFkfgPZZ2SpBsUcVnvwvL4DAVUORVnWbddnlt8=";
    };
  });
in {
  archlinux = recurseIntoAttrs (import ./archlinux {
    inherit pkgs rp;
  });
  
  lx-music-desktop = callPackage ./electronAppImage rec {
    pname = "lx-music-desktop";
    version = "2.1.0";
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    src = fetchurl {
      url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
      hash = "sha256-PVV9EYY+/jw+QwqPqxfqKvo/BDP/y1kDVSlyOYywzss=";
    };
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages/override.nix {
    inherit pkgs;
  });

  ppet = callPackage ./electronAppImage rec {
    electron = electron_19_1;
    pname = "ppet3";
    version = "3.3.0";
    description = "Live2D on desktop";
    homepage = "https://github.com/zenghongtu/PPet";
    license = lib.licenses.mit;
    src = fetchurl {
      url = "${rp}${homepage}/releases/download/v${version}/PPet3-${version}.AppImage";
      hash = "sha256-zdRZm0T6tBqNxvaUaiWAlAfuug/CQX0S+B5uDNdiQ/s=";
    };
  };
}