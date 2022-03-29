{ stdenv
, lib
, alsaLib
, dbus
, libpulseaudio
, libva
, openssl
, udev
, xorg
, fetchurl
, dpkg
, autoPatchelfHook
, libglvnd
, libX11
, libGL
}:

stdenv.mkDerivation rec {
  pname = "parsec";
  version = "1.0"; # Can't seem to find versioning upstream?

  src = fetchurl {
    url = "https://builds.parsecgaming.com/package/parsec-linux.deb"; # Can't seem to find a link to a specific version, hopefully this wont change invalidating the derivation.
    sha256 = "1hfdzjd8qiksv336m4s4ban004vhv00cv2j461gc6zrp37s0fwhc";
  };

  unpackPhase = "dpkg-deb -x ${src} .";

  nativeBuildInputs = [ 
    dpkg
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -r . $out


    echo '#!/usr/bin/env bash' > $out/bin/parsecd
    echo "export _wrapped_bin=$out/usr/bin/parsecd" >> $out/bin/parsecd
    echo "export LD_LIBRARY_PATH=${lib.makeLibraryPath [
      stdenv.cc.cc.lib libglvnd libX11 libGL  alsaLib (lib.getLib dbus) libGL libpulseaudio libva.out
      (lib.getLib openssl) (lib.getLib stdenv.cc.cc) (lib.getLib udev)
      xorg.libXi xorg.libXcursor
    ]}" >> $out/bin/parsecd
    echo 'mkdir -p ~/.parsec' >> $out/bin/parsecd
    echo "for f in $out/usr/share/parsec/skel/*; do" >> $out/bin/parsecd
    echo 'cp -u "$f" ~/.parsec/$(basename $f) || true' >> $out/bin/parsecd
    echo 'chmod 755 ~/.parsec/$(basename $f)' >> $out/bin/parsecd
    echo "done" >> $out/bin/parsecd
    echo 'exec $_wrapped_bin "$@"' >> $out/bin/parsecd
    chmod +x $out/bin/parsecd
  '';

  meta = with lib; {
    homepage = "https://parsecgaming.com/";
    description = "Remote streaming service client";
    license = licenses.unfree;
    maintainers = with maintainers; [ ivar ];
    platforms = platforms.linux;
  };
}
