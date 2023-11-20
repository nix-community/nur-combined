{ lib
, stdenv
, fetchurl
, fetchpatch
, python3
, libxslt
, docbook-xsl-ns
, installShellFiles
, wget
, cacert
}:
stdenv.mkDerivation
rec {
  version = "1.6.2-1";
  pname = "pastebinit";

  src = fetchurl {
    url = "https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/${pname}/${version}/${pname}_${lib.removeSuffix "-1" version}.orig.tar.gz";
    sha256 = "b7f63207bfb66eca0e77052283815346d3ad9de2b30aa9f68b74521f0b54940a";
  };

  patches = [
    ./use-drv-etc.patch
  ];

  nativeBuildInputs = [
    libxslt
    installShellFiles
  ];

  buildInputs = [
    (python3.withPackages (p: [ p.distro ]))
  ];

  buildPhase = ''
    xsltproc --nonet ${docbook-xsl-ns}/share/xml/docbook-xsl-ns/manpages/docbook.xsl pastebinit.xml
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/etc
    cp -a pastebinit $out/bin
    cp -a pastebin.d $out/etc
    substituteInPlace $out/bin/pastebinit --subst-var-by "etc" "$out/etc"
    installManPage pastebinit.1
  '';

  meta = with lib; {
    homepage = "https://launchpad.net/ubuntu/+source/pastebinit";
    description = "A software that lets you send anything you want directly to a pastebin from the command line";
    maintainers = with maintainers; [ raboof ];
    license = licenses.gpl2;
    platforms = platforms.linux ++ lib.platforms.darwin;
  };
}
