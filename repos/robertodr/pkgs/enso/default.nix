{ lib, stdenv, fetchurl, appimageTools, undmg }:

let
  pname = "enso";
  version = "2022.1.1-nightly.2022-10-15";
  name = "${pname}-linux-${version}";

  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix = {
    x86_64-linux = "AppImage";
    x86_64-darwin = "dmg";
  }.${system} or throwSystem;

  src = fetchurl {
    url = "https://github.com/enso-org/enso/releases/download/${version}/${name}.AppImage";
    name = "${name}.AppImage";
    sha256 = {
      x86_64-linux = "sha256-RngPrpjuONXudlZ35Nz5j4b8StXGqDAnrzwUaHjj2XY=";
      x86_64-darwin = "1kd491v112h8xd1wn33srgjhxyklgxd3vmi7ww95glw8268n5561";
    }.${system} or throwSystem;
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };

  meta = with lib; {
    description = "Hybrid visual and textual functional programming.";
    homepage = "https://enso.org/";
    license = licenses.asl20;
    maintainers = with maintainers; [ robertodr ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };

  linux = appimageTools.wrapType2
    rec {
      inherit name src meta;

      multiPkgs = null; # no 32bit needed
      extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;

      extraInstallCommands = ''
        mv $out/bin/${name} $out/bin/${pname}
        install -m 444 -D ${appimageContents}/enso.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/enso.desktop \
          --replace 'Exec=AppRun --no-sandbox' 'Exec=${pname}'
        install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/16x16/apps/enso.png \
          $out/share/icons/hicolor/32x32/apps/enso.png
      '';
    };

  darwin = stdenv.mkDerivation {
    inherit name src meta;

    nativeBuildInputs = [ undmg ];

    sourceRoot = "Enso.app";

    installPhase = ''
      mkdir -p $out/Applications/Enso.app
      cp -R . $out/Applications/Enso.app
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
