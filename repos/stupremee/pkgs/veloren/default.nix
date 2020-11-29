{ lib, stdenv, fetchzip, fetchurl, autoPatchelfHook, xorg, gtk3, udev, alsaLib
, gobject-introspection, unzip }:
let
  pname = "veloren";
  latestStable = "0.7.0";

  commonPackage = {
    dontBuild = true;

    nativeBuildInputs = [ autoPatchelfHook gtk3 udev alsaLib xorg.libxcb ];

    installPhase = ''
      install -D ./veloren-voxygen -t $out/bin
      install -D ./veloren-server-cli -t $out/bin
      mkdir -p $out/share/veloren
      cp -a assets $out/share/veloren/
    '';

    meta = with lib; {
      description =
        "Veloren is an open-world, open-source multiplayer voxel RPG. The game is in an early stage of development, but is playable.";
      homepage = "https://veloren.net/";
      platforms = [ "x86_64-linux" ];
      license = licenses.gpl3;
    };
  };
in {
  stable = stdenv.mkDerivation rec {
    inherit pname;
    version = latestStable;

    src = fetchzip {
      url =
        "https://veloren-4129.fra1.digitaloceanspaces.com/releases/${version}-linux.tar.gz";
      sha256 = "sha256-HOyrnm34GViQTvglk6EgWCX07MkAfI/+eEtahgRelEw=";
      stripRoot = false;
    };

    inherit (commonPackage) dontBuild nativeBuildInputs installPhase meta;
  };

  nightly = stdenv.mkDerivation {
    inherit pname;
    version = "nightly";

    src = fetchurl {
      url = "https://download.veloren.net/latest/linux";
      sha256 = "sha256-oFrCXCoCuM4ax0yLkXYTp3zknS5MAeOyVjkj4dc31Fg=";
    };
    buildInputs = [ unzip ];

    unpackPhase = ''
      unzip $src
    '';

    inherit (commonPackage) dontBuild nativeBuildInputs installPhase meta;
  };
}
