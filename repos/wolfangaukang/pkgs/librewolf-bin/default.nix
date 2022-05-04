{ lib, stdenv, fetchurl, appimageTools, undmg }:
let
  pname = "librewolf-bin";
  version = "99.0.1-4";
  name = "${pname}-${version}";

  srcs = {
    # Picked SHA from $PROJECT_URL/-/packages and package URL from $PROJECT_URL/-/releases
    x86_64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}/LibreWolf.x86_64.AppImage";
      sha256 = "e1096b23097524a706103b8694fd1bce9a17101b6d818c2d609028f7c2822b44";
    };
    aarch64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}/LibreWolf.aarch64.AppImage";
      sha256 = "0484a61f05a516cdb24ed39a10653f793c5d8392873e4026c758ad96878bb3be";
    };
    # Picked from $PROJECT_URL/-/releases
    x86_64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/ce11b221ea2eedc393ffbc66d204a354/librewolf-${version}.en-US.mac.x86_64.dmg";
      sha256 = "8aa26587558cd57b580bd8b6096e9c468e6408209b5906d88f37169a71d5658f";
    };
    aarch64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/c3d63e216716b9ec2e21dec3d1c562bc/librewolf-${version}.en-US.mac.aarch64.dmg";
      sha256 = "5c51f5368bf11b4fecd225543f447b46208dc9c1b62c7a75fa43d6a0809ead19";
    };
  };
  src = srcs.${stdenv.hostPlatform.system};

  meta = with lib; {
    description = "A fork of Firefox, focused on privacy, security and freedom";
    homepage = "https://librewolf-community.gitlab.io/";
    license = licenses.mpl20;
    maintainers = with maintainers; [ sikmir wolfangaukang ];
    platforms = builtins.attrNames srcs;
    skip.ci = true;
  };

  appimageContents = appimageTools.extract {
    inherit name src;
  };

  linux = appimageTools.wrapType2 rec {
    inherit name src meta;

    extraInstallCommands = ''
      mv $out/bin/{${name},${pname}}
      install -Dm644 ${appimageContents}/io.gitlab.LibreWolf.desktop -t $out/share/applications
      install -Dm644 ${appimageContents}/librewolf.png -t $out/share/icons/hicolor/256x256/apps
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [ undmg ];

    sourceRoot = ".";

    installPhase = ''
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
