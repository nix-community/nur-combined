{ stdenv, buildPackages, fetchFromGitHub
, ffmpeg, libvitamtp
, gdk_pixbuf ? null, libnotify ? null
}:

let
  inherit (stdenv.lib) chooseDevOutputs optionals;
in stdenv.mkDerivation rec {
  pname = "qcma";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "codestation";
    repo = "qcma";
    # 0.4.2 isn't tagged?
    # rev = "v${version}";
    rev = "65f0eab8ca0640447d2e84cdc5fadc66d2c07efb";
    sha256 = "1i8g4w05s1dalqyl42v6fmcng84nn95gd7vh3vvx4hg2bikdc5h3";
  };

  outputs = [ "out" "man" ];
  outputBin = "out";

  nativeBuildInputs = [
    buildPackages.pkgconfig
    buildPackages.qmake
    buildPackages.qttools
  ];
  buildInputs = let
    inherit (stdenv) hostPlatform;
  in chooseDevOutputs ([
    ffmpeg
    libvitamtp
  ] ++ optionals (hostPlatform.isUnix && !hostPlatform.isDarwin) [
    gdk_pixbuf
    libnotify
  ]);

  preConfigure = ''
    lrelease common/resources/translations/*.ts
  '';

  meta = with stdenv.lib; {
    description = "Cross-platform content manager assistant for the PS Vita";
    homepage = https://codestation.github.io/qcma/;
    downloadPage = https://github.com/codestation/qcma/releases;
    license = with licenses; gpl2;
    maintainers = with maintainers; [ bb010g ];
    platforms = with platforms; all;
  };
}
