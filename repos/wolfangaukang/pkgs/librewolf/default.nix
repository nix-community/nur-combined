{ lib, stdenv, fetchurl, appimageTools, undmg }:
let
  pname = "librewolf";
  version = "93.0-1";
  name = "${pname}-${version}";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/appimage/-/jobs/1662565348/artifacts/raw/LibreWolf-${version}.x86_64.AppImage";
      hash = "sha256-1Rxv1dZ/kwhhHdvm34XphnbQlDXTkSVy9pjQ525S4eo=";
    };
    aarch64-linux = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/appimage/-/jobs/1662565349/artifacts/raw/LibreWolf-${version}.aarch64.AppImage";
      hash = "sha256-zuXGDptHULbFaINHJERJd7qEUmWqsoKjWiQwgtNVMmQ=";
    };
    x86_64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/9324cabdb1a0677c6a2ed5847ccb5eb8/librewolf-${version}.dmg";
      hash = "sha256-g8ujnFyspbT2QrTyxwyAapCSAPGJ26cOv93VBgsWKUk=";
    };
    aarch64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/e092796aa6d554c4bbe5687426e06bb1/librewolf-${version}_aarch64_exp.dmg";
      hash = "sha256-/0ILIFirJB31VuNbDnRDOv2CWovJ4TnVYzjNdhi8PTU=";
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
