{ lib, stdenv, fetchurl, appimageTools, undmg }:
let
  pname = "librewolf-bin";
  version = "96.0.3-2";
  name = "${pname}-${version}";

  srcs = {
    # Picked SHA from $PROJECT_URL/-/packages and package URL from $PROJECT_URL/-/releases
    x86_64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}/LibreWolf.x86_64.AppImage";
      sha256 = "8e7d8242f92cd5aa2c5903b4f08eba75d5fdee2f1c1a294da91d1fb8bbe68c1e";
    };
    aarch64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}/LibreWolf.aarch64.AppImage";
      sha256 = "3a083d40b862df383980c9d44021ff8cafe6b7f9328d1e8265d9c263016b9284";
    };
    # Picked from $PROJECT_URL/-/releases
    x86_64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/dd4be5c05d04d8fa4a9134ee13bc2e33/librewolf-${version}.dmg";
      sha256 = "3a45392bac62cf11e1153fd83cdedeb90b8acfc93d9e31d97f7853625973a187";
    };
    aarch64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/199aedb468a551b3c1371f974487502f/librewolf-${version}_aarch64_exp.dmg";
      sha256 = "ce576f5cce6fa2fe78bb5afe4706358be1b72d3b30630617a8768d99e9ca4fce";
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
