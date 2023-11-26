# SPDX-FileCopyrightText: 2023 5aaee9 <7685264+5aaee9@users.noreply.github.com>
# SPDX-FileCopyrightText: 2023 fictionbecomesfact <93423494+fictionbecomesfact@users.noreply.github.com>

# SPDX-License-Identifier: MIT

{ lib, stdenv, fetchzip, gettext }:

stdenv.mkDerivation rec {
  pname = "cockpit-machines";
  version = "302";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-machines/releases/download/${version}/cockpit-machines-${version}.tar.xz";
    sha256 = "sha256-3dfB9RzFzN578djOSdANVcb0AZ0vpSq6lIG7uMwzAVU=";
  };

  nativeBuildInputs = [
    gettext
  ];

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/share $out/share
    touch pkg/lib/cockpit.js
    touch pkg/lib/cockpit-po-plugin.js
    touch dist/manifest.json
  '';

  postFixup = ''
    gunzip $out/share/cockpit/machines/index.js.gz
    sed -i "s#/usr/bin/python3#/usr/bin/env python3#ig" $out/share/cockpit/machines/index.js
    sed -i "s#/usr/bin/pwscore#/usr/bin/env pwscore#ig" $out/share/cockpit/machines/index.js
    gzip -9 $out/share/cockpit/machines/index.js
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
