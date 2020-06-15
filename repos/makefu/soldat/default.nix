{ stdenv,fpc,zip, fetchFromGitHub, autoPatchelfHook, callPackage,
freetype,openal,x11,SDL2,physfs_2, protobuf, openssl, cmake, ninja,
meson,pkgconfig, makeWrapper }:

let
  GameNetworkingSockets = stdenv.mkDerivation rec {
    pname = "GameNetworkingSockets";
    version = "2020-02-27";

    src = fetchFromGitHub {
      sha256 = "1vlrqjpqmdv1gphj2bkqg0bljqxfv75say6vrcnk9z14irih9a24";
      owner = "ValveSoftware";
      repo = pname;
      rev = "36d41513e9a25d7ad4c2b37826d6594aaf185374";
    };

    mesonFlags = [ "-Dlight_tests=true" ];

    buildInputs = [ protobuf openssl ];
    nativeBuildInputs = [ pkgconfig meson cmake ninja ];
    installPhase = ''
      mkdir -p $out/lib $out/include; find .
      cp src/libGameNetworkingSockets.so $out/lib/
      cp -r ../include $out/
    '';


    #outputs = [ "out" "dev" "lib" ];

    meta = with stdenv.lib; {
      description = "WebDav server implementation and library using libsoup";
      homepage = "https://wiki.gnome.org/phodav";
      license = licenses.lgpl21;
      maintainers = with maintainers; [ gnidorah ];
      platforms = platforms.linux;
    };
  };
  base = stdenv.mkDerivation {
    pname = "soldat-base";
    version = "1.0.0";
    src = fetchFromGitHub {
      repo = "base";
      owner = "soldat";
      rev = "3c002b9";
      sha256 = "1wc1cmdavf6ng05wfcpxn124n23vivx4nn06irqmar6jmrklrbq0";
    };
    buildInputs = [ zip ];
    buildPhase = ''
      sh ./create_smod.sh
    '';
    installPhase = ''
      install -D soldat.smod $out/soldat.smod
      install -D client/play-regular.ttf $out/play-regular.ttf
    '';
  };
  src = fetchFromGitHub {
      repo = "soldat";
      owner = "soldat";
      rev = "6dee4d0";
      sha256 = "0jjgdxprlvyf5kh2mb48vrp5nxk3h3jbaxmy7xmna80ssx4bjhxf";
    };
  stb =  stdenv.mkDerivation {
    pname = "soldat";
    version = "1.0.0";
    inherit src;
    # makeFlags = [ "CFLAGS='-Fl${openal}/lib'" ];
    buildPhase = ''
      cd client
      mkdir -p build/linux
      make -C libs/stb/
    '';
    installPhase = ''
      install -D build/libstb.so $out/lib/libstb.so
    '';

    buildInputs = [ ];
  };
in
stdenv.mkDerivation {
  pname = "soldat";
  version = "1.0.0";
  inherit src;
  # makeFlags = [ "CFLAGS='-Fl${openal}/lib'" ];
  buildPhase = ''
    cd client
    mkdir -p build/linux
    make -C libs/stb/
    make linux_x86_64
    cd ../server
    mkdir -p build/linux
    make linux_x86_64
    cd ..
  '';

  # TODO: soldatserver still needs to be copied out of the derivation to somewhere writeable
  installPhase = ''
    share=$out/share/soldat
    bin=$out/bin
    mkdir -p $share $bin

    install ${base}/soldat.smod $share/soldat.smod
    install ${base}/play-regular.ttf $share/play-regular.ttf;

    install -m755 client/build/soldat_x64 $share/soldat_x64
    install client/media/soldat.ico $share/soldat.ico

    install -m755 server/build/soldatserver_x64 $share/soldatserver_x64

    makeWrapper $share/soldat_x64 $bin/soldat --add-flags '-fs_portable 0'
    makeWrapper $share/soldatserver_x64 $bin/soldatserver --add-flags '-fs_userpath ~/.local/share/Soldat/Soldat'
  '';

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [
    fpc freetype openal x11 SDL2 physfs_2 GameNetworkingSockets  stb
  ];
}

