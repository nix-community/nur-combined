{ lib, stdenv, fetchzip, gettext }:

stdenv.mkDerivation rec {
  pname = "cockpit-machines";
  version = "313";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-machines/releases/download/${version}/cockpit-machines-${version}.tar.xz";
    sha256 = "sha256-Fcou7io8qN0i+EaZDr6EA7eQfKsaOi8H7XTMlHU6kGo=";
  };

  nativeBuildInputs = [
    gettext
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postPatch = ''
    touch pkg/lib/cockpit.js
    touch pkg/lib/cockpit-po-plugin.js
    touch dist/manifest.json
  '';

  dontBuild = true;

  meta = with lib; {
    description = "Cockpit UI for virtual machines";
    license = licenses.lgpl21;
    homepage = "https://github.com/cockpit-project/cockpit-machines";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
