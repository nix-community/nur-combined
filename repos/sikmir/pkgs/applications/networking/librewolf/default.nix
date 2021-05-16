{ lib, stdenv, fetchurl, appimageTools, undmg }:
let
  pname = "librewolf";
  version = "88.0.1";
  name = "${pname}-${version}";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/appimage/-/jobs/1246930630/artifacts/raw/LibreWolf-${version}-1.x86_64.AppImage";
      hash = "sha256-5W7wO0DJJTbC6B8N+i6hjKImrEvhjUUsVTxkzWQXyOQ=";
    };
    aarch64-linux = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/appimage/-/jobs/1246930548/artifacts/raw/LibreWolf-${version}-1.aarch64.AppImage";
      hash = "sha256-cHDs5eaPNaS7Eng0GMDvRMaAKYKJxezWfU2QkXanSO4=";
    };
    x86_64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/271c8180431a4e05ad7159626dfba5ec/librewolf-${version}-2_x86.dmg";
      hash = "sha256-0SCQOx350hLklS/HA+IimKD6S0fc6FC5P5MU660ij3Y=";
    };
    aarch64-darwin = fetchurl {
      url = "https://gitlab.com//librewolf-community/browser/macos/uploads/02461b5e5f59b74c1fdd0e0682a65124/librewolf-${version}-2_aarch64_exp.dmg";
      hash = "sha256-e2rXWNjPiybRK6nw4hOiCxnLQ/z3pLOMZw7zO/mk9Ek";
    };
  };
  src = srcs.${stdenv.hostPlatform.system};

  meta = with lib; {
    description = "A fork of Firefox, focused on privacy, security and freedom";
    homepage = "https://librewolf-community.gitlab.io/";
    license = licenses.mpl20;
    maintainers = [ maintainers.sikmir ];
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
