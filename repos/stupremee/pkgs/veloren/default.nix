{ lib, stdenv, pkgs, makeWrapper, autoPatchelfHook, fetchzip, alsaLib, xorg
, libudev, libX11, libXcursor, libXrandr, libXi }:
let
  pname = "veloren";
  latestStable = "0.8.0";

  #commonPackage = {
  #dontBuild = true;

  #nativeBuildInputs = [ autoPatchelfHook gtk3 udev alsaLib xorg.libxcb ];

  #installPhase = ''
  #install -D ./veloren-voxygen -t $out/bin
  #install -D ./veloren-server-cli -t $out/bin
  #mkdir -p $out/share/veloren
  #cp -a assets $out/share/veloren/
  #'';

  #};
  meta = with lib; {
    description =
      "Veloren is an open-world, open-source multiplayer voxel RPG. The game is in an early stage of development, but is playable.";
    homepage = "https://veloren.net/";
    platforms = [ "x86_64-linux" ];
    license = licenses.gpl3;
  };
in {
  stable = stdenv.mkDerivation rec {
    inherit pname;
    version = latestStable;

    src = fetchzip {
      url =
        "https://veloren-4129.fra1.digitaloceanspaces.com/releases/${version}-linux.tar.gz";
      sha256 = "sha256-tnmQYEqdd6TUoaSddESUwMTjk7RcYngSObI6P+OYUmg=";
      stripRoot = false;
    };
    buildInputs =
      [ alsaLib xorg.libxcb libudev libX11 libXcursor libXrandr libXi ];
    nativeBuildInputs = [ makeWrapper autoPatchelfHook ];
    installPhase = ''
      mkdir -p $out/bin
      cp -a ./assets $out
      install -D ./veloren-voxygen -t $out/bin
      install -D ./veloren-server-cli -t $out/bin

      wrapProgram $out/bin/veloren-voxygen --set VELOREN_ASSETS $out/
      wrapProgram $out/bin/veloren-server-cli --set VELOREN_ASSETS $out/
    '';

    inherit meta;
  };
}
