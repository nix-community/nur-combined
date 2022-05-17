{ lib, stdenv, fetchurl, appimageTools, undmg }:
let
  pname = "librewolf-bin";
  # As of 2022-05-14, Linux does not have 100.0-3, and macOS does not have 100.0-2
  version = "100.0";
  name = "${pname}-${version}";

  srcs = {
    # Picked SHA from $PROJECT_URL/-/packages and package URL from $PROJECT_URL/-/releases
    x86_64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}-2/LibreWolf.x86_64.AppImage";
      sha256 = "dc24cdecc372fb33de73c2bb07233e706171551c381c78c4e4045397238cf1bd";
    };
    aarch64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}-2/LibreWolf.aarch64.AppImage";
      sha256 = "6d7000e782b3f7304579a45f50fb4404b65a25d3dc6298637ca57778d36166f6";
    };
    # Picked from $PROJECT_URL/-/releases
    x86_64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/e7345295904e99340fff3b7a07e0cc68/librewolf-${version}-3.en-US.mac.x86_64.dmg";
      sha256 = "8cbc6b29b55e05d96ba6a54f1f40ed2574d7df287a1f65e185c8a2bf7fab7e0f";
    };
    aarch64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/9717d20cf8c54f1f0083d2be37286e5c/librewolf-${version}-3.en-US.mac.x86_64.dmg";
      sha256 = "1d8b3c25e72c8b78c689e11e2f25bc5285096057512164d1a524dc7b4c970b86";
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
