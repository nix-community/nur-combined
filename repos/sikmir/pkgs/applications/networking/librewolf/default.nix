{ lib, stdenv, fetchurl, appimageTools, undmg }:
let
  pname = "librewolf";
  version = "94.0.2";

  srcs = {
    x86_64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}-2/LibreWolf.x86_64.AppImage";
      hash = "sha256-ciD0kOVt3mwckuXQwX+wrXyIsxy1cki6S58W8aBABDw=";
    };
    aarch64-linux = fetchurl {
      url = "https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/${version}-2/LibreWolf.aarch64.AppImage";
      hash = "sha256-03/JuyoqxuweQ6RsQ59QUG0uKogA+OT1WBgHeR/VBrg=";
    };
    x86_64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/af4732e68ec6219135288af9fffdd920/librewolf-${version}-1.dmg";
      hash = "sha256-gTlQKHgcGlm/YNXmG5YMrfcwKC+P5Wc0Dmj4rqvguD8=";
    };
    aarch64-darwin = fetchurl {
      url = "https://gitlab.com/librewolf-community/browser/macos/uploads/28eb3a54b3a320cdb09773e848e681d2/librewolf-${version}-1_aarch64_exp.dmg";
      hash = "sha256-iDHS4UODdQWXxHfiyVJi1AO8JbFe0fKrQjryjz4339M=";
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
    inherit pname version src;
  };

  linux = appimageTools.wrapType2 rec {
    inherit pname version src meta;

    extraInstallCommands = ''
      mv $out/bin/{${pname}-${version},${pname}}
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
