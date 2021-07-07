{ stdenv, fetchFromGitHub, obs-studio, libX11, libjpeg_turbo, libusbmuxd, ffmpeg, pkg-config }: stdenv.mkDerivation rec {
  pname = "droidcam-obs";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "dev47apps";
    repo = "droidcam-obs-plugin";
    rev = version;
    sha256 = "15fdbkd1i1yy9nmspsi335a6yn49r9c2wxs8y4k5x5gy0hzl6031";
  };

  postPatch = ''
    sed -i \
      -e 's/<obs-/<obs\/obs-/' \
      -e 's/<obs\./<obs\/obs./' \
      -e 's/<util\//<obs\/util\//' \
      src/*.c src/*.h
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ obs-studio libjpeg_turbo libusbmuxd ffmpeg libX11 ];

  libname = pname + stdenv.hostPlatform.extensions.sharedLibrary;
  sysname = if stdenv.hostPlatform.isWindows then "win" else "unix";
  buildPhase = ''
    runHook preBuild

    $CXX -I src \
      -std=c++11 -DRELEASE=1 \
      src/*.c src/sys/$sysname/*.c \
      $(pkg-config --cflags --libs libobs libavcodec libavformat libavutil libturbojpeg libusbmuxd-2.0) \
      -lobs-frontend-api \
      -shared -o $libname

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm0755 -t $out/lib/obs-plugins $libname

    install -d $out/share/obs/obs-plugins/${pname}
    mv data/locale $out/share/obs/obs-plugins/${pname}

    runHook postInstall
  '';
}
