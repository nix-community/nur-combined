{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, makeWrapper
, zstd
, zlib
, libcxx
, fontconfig
, icu
, openssl
, ...
}:

stdenv.mkDerivation rec {
  pname = "watt-toolkit";
  version = "2.8.4";
  src = fetchurl {
    url = "https://github.com/BeyondDimension/SteamTools/releases/download/${version}/Steam++_linux_x64_v${version}.tar.zst";
    sha256 = "sha256-VDmPp/3ccl3yY7zhMYQhUcSqe83TwZ51x3UeHpo+V9M=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper zstd ];
  buildInputs = [
    zlib
    libcxx
    fontconfig
    icu
    openssl
  ];

  unpackPhase = ''
    tar xf $src
  '';

  installPhase = ''
        mkdir -p $out/opt/watt-toolkit
        mkdir -p $out/share/applications
        mkdir -p $out/share/icons/hicolor/64x64/apps
        mkdir -p $out/bin

        rm -rf Steam++.sh Steam++.ico Exit.sh

        cp -r * $out/opt/watt-toolkit/
        cp ${./icon.png} $out/share/icons/hicolor/64x64/apps/watt-toolkit.png
        cp ${./watt-toolkit.desktop} $out/share/applications/watt-toolkit.desktop

    		substituteInPlace $out/share/applications/watt-toolkit.desktop \
        	--replace /usr/bin/watt-toolkit $out/bin/watt-toolkit

        makeWrapper $out/opt/watt-toolkit/Steam++ $out/bin/watt-toolkit \
          --argv0 "Steam++" \
          --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
  '';

  meta = with lib; {
    description = "A cross-platform Steam toolbox";
    homepage = "https://steampp.net/";
    changelog = "https://github.com/BeyondDimension/SteamTools/releases/tag/${version}";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
