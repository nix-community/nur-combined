{ stdenv, fetchFromGitHub, cmake, qmake }:
stdenv.mkDerivation rec {
  name = "uefitool-${version}";
  version = "A53";

  src = fetchFromGitHub {
    owner = "LongSoft";
    repo = "UEFITool";
    rev = version;
    sha256 = "07gchb26mjla8ir8cwm59341fdzzjhdq7pc3dfbl2kiz8p56x6i2";
  };

  sourceRoot = "source/UEFITool";

  configurePhase = ''
    qmake uefitool.pro
  '';

  nativeBuildInputs = [ cmake qmake ];

  installPhase = ''
    mkdir -p $out/bin
    mv UEFITool $out/bin/
  '';
  
  meta = with stdenv.lib; {
    description = "UEFI firmware image viewer and editor";
    license = licenses.bsd3;
    homepage = https://github.com/LongSoft/UEFITool;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

