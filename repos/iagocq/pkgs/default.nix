{ pkgs }:

let
  callPackage = pkgs.callPackage;
in
{
  lightspeed-ingest = callPackage ./lightspeed-ingest { };
  lightspeed-react = callPackage ./lightspeed-react { };
  lightspeed-webrtc = callPackage ./lightspeed-webrtc { };
  parprouted = callPackage ./parprouted { };
  parsec = callPackage ./parsec { };

  pptpd = pkgs.pptpd.overrideAttrs (old: {
    configureFlags = [ "--enable-bcrelay" ];
  });

  telegram-send = callPackage ./telegram-send { };
  truckersmp-cli = callPackage ./truckersmp-cli { };

  zig = (pkgs.zig.override { llvmPackages = pkgs.llvmPackages_13; }).overrideAttrs (old: rec {
    version = "0.10.0-dev";
    src = pkgs.fetchFromGitHub {
      owner = "ziglang";
      repo = "zig";
      rev = "a5c7742ba6fc793608b8bb7ba058e33eccd9cfec";
      hash = "sha256-nObE1WX5nY40v6ryaAB75kVKeE+Q76yKgfR/DYRDcwA=";
    };
  });

  zls = pkgs.zls.overrideAttrs (old: rec {
    version = "0.2.0";
    src = pkgs.fetchFromGitHub {
      fetchSubmodules = true;
      owner = "zigtools";
      repo = "zls";
      rev = "189de1768dfc95086a15664123c11144e9ac1402";
      sha256 = "sha256-iTYwK76N0efm/e0JZbxKKZ/j+dej9BX/SNWeox+iLjA=";
    };
  });

  multimc = pkgs.multimc.overrideAttrs (old: rec {
    src = pkgs.fetchFromGitHub {
      fetchSubmodules = true;
      owner = "AfoninZ";
      repo = "MultiMC5-Cracked";
      rev = "deffca3b6f84cfe0d5932b096da7ec216f3408df";
      sha256 = "sha256-qJwXCVDJ2EAfGlHEgdkIFSaZv2AGF2oUjcRdc2XU8jI=";
    };

    postInstall = ''
      #install -Dm644 ../launcher/resources/multimc/scalable/multimc.svg $out/share/pixmaps/multimc.svg
      #install -Dm755 ../launcher/package/linux/multimc.desktop $out/share/applications/multimc.desktop
      # xorg.xrandr needed for LWJGL [2.9.2, 3) https://github.com/LWJGL/lwjgl/issues/128
      chmod -x $out/bin/*.so
      wrapProgram $out/bin/DevLauncher \
        --set GAME_LIBRARY_PATH /run/opengl-driver/lib:${with pkgs.xorg; pkgs.lib.makeLibraryPath [ libX11 libXext libXcursor libXrandr libXxf86vm pkgs.libpulseaudio pkgs.libGL ]} \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xorg.xrandr ]}
    '';
  });
}
