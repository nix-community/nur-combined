{ 
  pkgs ? import <nixpkgs> {},
  rp ? "",
}:

with pkgs; rec {
  archlinux = recurseIntoAttrs (import ./archlinux {
    inherit pkgs rp;
  });

  electron_2 = electron.overrideAttrs (old: rec {
    version = "2.0.18";
    src = fetchurl {
      url = "${rp}https://github.com/electron/electron/releases/download/v${version}/electron-v${version}-linux-x64.zip";
      sha256 = "f196e06b6ecfa33bffb02b3d6c4a64bd5a076014e2f21c4a67356474ee014000";
    };
    postFixup = ''
      patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${atomEnv.libPath}:${lib.makeLibraryPath [
            libuuid at-spi2-atk at-spi2-core libappindicator-gtk3
            gnome2.GConf
          ]}:$out/lib/electron" \
          $out/lib/electron/electron
      wrapProgram $out/lib/electron/electron "''${gappsWrapperArgs[@]}"
    '';
  });
  
  gnomeExtensions = recurseIntoAttrs (import ./gnomeExtensions {
    inherit pkgs rp;
  });

  jnu-open = callPackage ./jnu-open { inherit rp; };
  
  lx-music-desktop = callPackage ./electronAppImage rec {
    pname = "lx-music-desktop";
    version = "1.22.3";
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    src = fetchurl {
      url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
      sha256 = "sha256-mlT1FOPeg9mMwOVmRdy+fm/PR3ME0RsftQ9BcIbuauI=";
    };
  };

  nodePackages = recurseIntoAttrs (import ./nodePackages {
    inherit pkgs;
  });

  ppet = callPackage ./electronAppImage rec {
    electron = electron_19;
    pname = "ppet3";
    version = "3.3.0";
    description = "Live2D on desktop";
    homepage = "https://github.com/zenghongtu/PPet";
    license = lib.licenses.mit;
    src = fetchurl {
      url = "${rp}${homepage}/releases/download/v${version}/PPet3-${version}.AppImage";
      sha256 = "sha256-zdRZm0T6tBqNxvaUaiWAlAfuug/CQX0S+B5uDNdiQ/s=";
    };
  };

  pypvz = callPackage ./pypvz { inherit rp; };

  wewechatpp = callPackage ./electronAppImage rec {
    electron = electron_2;
    pname = "wewechat";
    version = "1.2.4";
    description = "Make wewechat great again";
    homepage = "https://gitee.com/spark-community-works-collections/wewechat-plus-plus";
    license = lib.licenses.mit;
    src = fetchurl {
      url = "${rp}${homepage}/releases/download/${version}/wewechat-${version}-linux-x86_64.AppImage";
      hash = "sha256-hkyREXHnsccnvn5XAPETJBb0cUyvne2dgkd5k5FimfY=";
    };
    resourcesParentDir = "app";
  };
}