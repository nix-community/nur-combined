{ stdenv, fetchFromGitHub, kernel, bluez }:

stdenv.mkDerivation rec {
  pname = "xpadneo";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "atar-axis";
    repo = pname;
    rev = "v${version}";
    sha256 = "0j2kjbbpn3vgh3vwvjy2cvcb0hi56vnf634vxm56m001y55a8p4q";
  };

  setSourceRoot = ''
    export sourceRoot=$(pwd)/source/hid-xpadneo/src
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;
  buildInputs = [ bluez ];

  makeFlags = [
    "-C" "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)"
  ];

  buildFlags = [ "modules" ];
  installFlags = [ "INSTALL_MOD_PATH=$(out)" ];
  installTargets = [ "modules_install" ];

  meta = with stdenv.lib; {
    description = "Advanced Linux driver for Xbox One wireless controllers";
    homepage = "https://atar-axis.github.io/xpadneo";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
