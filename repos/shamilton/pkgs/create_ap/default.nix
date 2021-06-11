{ lib
, fetchFromGitHub
, stdenv
, makeWrapper
, coreutils
, dnsmasq
, gawk
, gnugrep
, gnused
, haveged
, hostapd
, iproute
, iw
, procps-ng
, utillinux
, wirelesstools
}:

stdenv.mkDerivation rec {
  pname = "create_ap";
  version = "2018-08-16";

  src = fetchFromGitHub {
    owner = "LinuxLearnorg";
    repo = "create_ap";
    rev = "50d28c625472ae0453f826bd8ccc8ee8b01ecd2c";
    sha256 = "05ds6as9mhsxrz6k87l2m1kc2mf2dmzw3qgkfc0ic9slc4rxr8ad";
  };
  
  # Disable systemd service installation
  patches = [ ./no-systemd-service.patch ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "/usr" "$out"
    substituteInPlace create_ap \
      --replace "which " "command -v "
  '';
  
  nativeBuildInputs = [ makeWrapper ];
  propagatedBuildInputs = [
    coreutils
    dnsmasq
    gawk
    gnugrep
    gnused
    haveged
    hostapd
    iproute
    iw
    procps-ng
    utillinux
    wirelesstools
  ];

  postInstall = ''
    wrapProgram "$out/bin/create_ap" --set PATH ${lib.makeBinPath propagatedBuildInputs}
  '';

  meta = with lib; {
    description = "Arcade Bombing Game";
    license = licenses.bsd2;
    homepage = "https://github.com/LinuxLearnorg/create_ap";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
