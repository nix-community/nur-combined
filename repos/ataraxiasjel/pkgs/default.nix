{ pkgs ? import <nixpkgs> { } }:

with pkgs; with lib; {
  lib = import ../lib { inherit pkgs; };
  modules = import ../modules;
  overlays = import ../overlays;

  a2ln = python3Packages.callPackage ./a2ln { };
  arkenfox-userjs = callPackage ./arkenfox-userjs { };
  bibata-cursors-tokyonight = callPackage ./bibata-cursors-tokyonight { };
  ceserver = callPackage ./ceserver { };
  gruvbox-plus-icons = callPackage ./gruvbox-plus-icons { };
  hoyolab-daily-bot = callPackage ./hoyolab-daily-bot { };
  koboldcpp-rocm = callPackage ./koboldcpp-rocm { };
  mpris-ctl = callPackage ./mpris-ctl { };
  proton-ge = callPackage ./proton-ge { };
  protonhax = callPackage ./protonhax { };
  reshade-shaders = callPackage ./reshade-shaders { };
  rpcs3 = qt6Packages.callPackage ./rpcs3 { };
  seadrive-fuse = callPackage ./seadrive-fuse { };
  sing-box = callPackage ./sing-box { };
  waydroid-script = callPackage ./waydroid-script { };
  wine-ge = callPackage ./wine-ge { };

  inherit (callPackage ./rosepine-gtk {}) rosepine-gtk-theme rosepine-gtk-icons;
  inherit (callPackage ./tokyonight-gtk {}) tokyonight-gtk-theme tokyonight-gtk-icons;
  roundcubePlugins = dontRecurseIntoAttrs (callPackage ./roundcube-plugins { });

  spotify-spotx = let
    spotify-ver = "1.2.13.661.ga588f749";
    spotx = stdenv.mkDerivation {
      pname = "spotx-bash";
      version = "unstable-2023-10-09";
      src = fetchFromGitHub {
        owner = "SpotX-Official";
        repo = "SpotX-Bash";
        rev = "62bafc47f7d07ac486e3d0f98e194beee50a0f02";
        hash = "sha256-fQGezRuOnIYMO2WYD4H+c26aQuL831rXWEpB+KRnyeM=";
      };
      dontBuild = true;
      nativeBuildInputs = [ makeBinaryWrapper ];
      installPhase = ''
        install -Dm 755 spotx.sh $out/bin/spotx
        substituteInPlace $out/bin/spotx --replace \
          'clientVer=$("''${appBinary}" --version | cut -d " " -f3- | rev | cut -d. -f2- | rev)' \
          'clientVer=$(echo "${spotify-ver}" | rev | cut -d. -f2- | rev)'
        sed -i 's/sxbLive=.\+/sxbLive=$buildVer/' $out/bin/spotx
        patchShebangs $out/bin/spotx
        wrapProgram $out/bin/spotx --prefix PATH : ${with pkgs; lib.makeBinPath [ perl unzip zip util-linux ]}
      '';
    };
  in pkgs.spotify.overrideAttrs (oa: {
    version = spotify-ver;
    postInstall = ''
      ${spotx}/bin/spotx -h -P "$out/share/spotify"
      rm -f "$out/share/spotify/Apps/xpui.bak" "$out/share/spotify/spotify.bak"
    '';
  });
}
