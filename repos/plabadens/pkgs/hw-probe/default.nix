{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, curl
, dmidecode
, edid-decode
, hwinfo
, pciutils
, perl
, systemd
, usbutils
, acpica-tools
, cpuid ? null
, drm_info
, glxinfo
, hdparm
, hplip
, i2c-tools
, inxi
, libva-utils
, mcelog
, memtester
, opensc
, sane-backends
, sysstat
, util-linux ? null
, vulkan-tools
, xinput
}:

stdenv.mkDerivation rec {
  pname = "hw-probe";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "linuxhw";
    repo = "hw-probe";
    rev = version;
    sha256 = "sha256-yIZQY5ZL7/nZqW/drpHtKRxEPURmrbk6tykb7lpWyv8=";
  };

  propagatedBuildInputs = [ perl ];

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [ "prefix=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/hw-probe --prefix PATH : ${
      lib.makeBinPath [
        curl
        dmidecode
        edid-decode
        hwinfo
        pciutils
        systemd
        usbutils

        acpica-tools
        cpuid
        drm_info
        glxinfo
        hdparm
        hplip
        i2c-tools
        inxi
        libva-utils
        mcelog
        memtester
        opensc
        sane-backends
        sysstat
        util-linux
        vulkan-tools
        xinput
      ]
    }
  '';

}
