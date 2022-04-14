{ lib, stdenv, fetchzip, gettext }:

stdenv.mkDerivation rec {
  pname = "cockpit-machines";
  version = "266";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-machines/releases/download/${version}/cockpit-machines-${version}.tar.xz";
    sha256 = "06anqm3im12sgnk16hfcp2h16xzlbxc0l7fq2b3n44bkfxhizjyx";
  };

  nativeBuildInputs = [
    gettext
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/share $out/share
  '';

  meta = with lib; {
    description = "Cockpit UI for virtual machines";
    license = licenses.lgpl21;
    homepage = "https://github.com/cockpit-project/cockpit-machines";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
