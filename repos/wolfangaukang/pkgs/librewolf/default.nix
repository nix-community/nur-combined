{ lib, stdenv, fetchurl, appimageTools, undmg }:
let
  pname = "librewolf";
  version = "95.0.2-1";
  name = "${pname}-${version}";

  srcs = {
    # Picked from $PROJECT_URL/-/releases
    x86_64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/${pname}/${version}/LibreWolf.x86_64.AppImage";
      sha256 = "e25016af59632c9f13509fa18196474880c476eb43c3ee6bb18919a6e2370675";
    };
    aarch64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/${pname}/${version}/LibreWolf.aarch64.AppImage";
      sha256 = "6ce7fc3e3c2024dcb8e371f6e090319a2d93337f02043f353ce0f56833014546";
    };
    x86_64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/dd4be5c05d04d8fa4a9134ee13bc2e33/librewolf-${version}.dmg";
      sha256 = "91bca5c96d725a70f9d73d622680064805bf3dbfcac0af36a44786d15437f0e6";
    };
    aarch64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/199aedb468a551b3c1371f974487502f/librewolf-${version}_aarch64_exp.dmg";
      sha256 = "70170da323506d6286008c13f781fb1de2f2332cec3f22406a1a61ee9b254a10";
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
