{ stdenv, fetchFromGitHub, qmake
, qtbase, imagemagick, fontconfig, libXft
}:

stdenv.mkDerivation rec {
  pname = "urxvtconfig";
  version = "unstable-2017-11-30";

  src = fetchFromGitHub {
    owner = "daedreth"; repo = "URXVTConfig";
    rev = "f5140f98b66b3d3b85f265297aded859f4d71235";
    sha256 = "0vflnjh3j0083619gy8jjb5bp2vkjnkdpl2qyzlkya55fwy2rgkv";
  };

  nativeBuildInputs = [
    qmake
  ];
  buildInputs = [
    qtbase imagemagick fontconfig libXft
  ];

  qmakeFlags = [
    "source/URXVTConfig.pro"
  ];
  preConfigure = ''
    substituteInPlace source/URXVTConfig.pro \
      --replace '/usr' "$out"
  '';

  meta = with stdenv.lib; {
    description = "A graphical user interface tool for configuration of the rxvt-unicode terminal emulator.";
    homepage = "https://github.com/daedreth/URXVTConfig";
    license = with licenses; lgpl3;
    maintainers = with maintainers; [
      arobyn
    ];
  };
}
