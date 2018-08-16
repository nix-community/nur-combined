{ stdenv, fetchFromGitHub, pkgconfig, qtbase, qmake, qttools, qtmacextras ? null, qtx11extras ? null, makeWrapper }:

let
  targetPath = isLinux: if isLinux then "bin" else "Applications";
in stdenv.mkDerivation rec {
  name = "qarma-${version}";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "luebking";
    repo = "qarma";
    rev = "6f5f60f396cab9fd4042bf3c27f4541e9967ddc2";
    sha256 = "0rrw85751vicbsdgawgshqim1069lf7v2v8sx212gqvklgi5ab5z";
  };

  buildInputs = [ makeWrapper pkgconfig qtbase qttools ]
    ++ stdenv.lib.optional stdenv.isLinux qtx11extras
    ++ stdenv.lib.optional stdenv.isDarwin qtmacextras;
  nativeBuildInputs = [ qmake ];

  preConfigure = ''
    qmakeFlags="$qmakeFlags QMAKE_LUPDATE=${qttools.dev}/bin/lupdate -after target.path=$out/${targetPath stdenv.isLinux}"
  '';
  postInstall =
    stdenv.lib.optionalString stdenv.isDarwin ''
    # Fixes "This application failed to start because it could not find or load the Qt
    # platform plugin "cocoa"."
    wrapProgram $out/Applications/qarma.app/Contents/MacOS/qarma \
      --set QT_QPA_PLATFORM_PLUGIN_PATH ${qtbase.bin}/lib/qt-*/plugins/platforms
    mkdir -p $out/bin
    ln -s $out/Applications/qarma.app/Contents/MacOS/qarma $out/bin/qarma
    '';
  meta = with stdenv.lib; {
    description = "A drop-in replacement clone for zenity, written in Qt4/5";
    homepage = https://github.com/luebking/qarma;
    license = licenses.gpl2;
    platforms = platforms.unix;
  };
}
