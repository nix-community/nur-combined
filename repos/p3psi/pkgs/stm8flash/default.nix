{ stdenv, fetchFromGitHub, libusb1, pkg-config }:

stdenv.mkDerivation rec {
  name = "stm8flash-${version}";
  version = "1.0";
  src = fetchFromGitHub {
    owner = "vdudouyt";
    repo = "stm8flash";
    rev = "1fe6521473dcc8615fcf77edc8e22ade6e6ccb56";
    sha256 = "1wzr7zbh503pp40qqfg0d264dcg8sk66a2z4gvgz59b6zzhix8z7";
  };

  buildInputs = [
    libusb1
    pkg-config
  ];

  buildPhase = "make";
  installPhase = ''
    mkdir -p $out/bin
    mv stm8flash $out/bin
  '';

  meta = with stdenv.lib; {
    description = "program your stm8 devices with SWIM/stlinkv(1,2)";
    homepage = "https://github.com/vdudouyt/stm8flash/";
    license = licenses.gpl2;
    maintainers = with maintainers; [ "vdudouyt" ];
    platforms = platforms.unix;
  };
}
