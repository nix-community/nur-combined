{ stdenv, lib, fetchFromGitHub, pkg-config
, xorg, asciidoc, makeWrapper
, dbus, libconfig, libdrm, libGL, pcre
, docbook_xml_dtd_45
, docbook_xsl, libxslt, libxml2
, ... }:

stdenv.mkDerivation rec {
  pname = "compton-kawase-blur";
  version = "0.1_beta2";

  src = fetchFromGitHub {
    owner  = "tryone144";
    repo   = "compton";
    rev = "241bbc50285e58cbc6a25d45066689eeea913880";
    sha256 = "148s7rkgh5aafzqdvag12fz9nm3fxw2kqwa8vimgq5af0c6ndqh2";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper

    xorg.xorgproto
    xorg.xprop
    xorg.xwininfo
    libdrm
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
  ];

  buildInputs = with xorg; [
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXext
    xorg.libXrender
    xorg.libXrandr
    xorg.libXinerama

    pcre
    libconfig
    libGL
    dbus

    libxml2
    libxslt
    # libxdg_basedir
  ];

  NIX_CFLAGS_COMPILE = [ "-fno-strict-aliasing" "-Wno-error=format-security" ];

  installFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/compton-trans \
      --prefix PATH : ${lib.makeBinPath [ xorg.xwininfo ]}
  '';

  meta = with lib; {
    description = "A fork of XCompMgr, a sample compositing manager for X servers";
    longDescription = ''
      A fork of XCompMgr, which is a sample compositing manager for X
      servers supporting the XFIXES, DAMAGE, RENDER, and COMPOSITE
      extensions. It enables basic eye-candy effects. This fork adds
      additional features, such as additional effects, and a fork at a
      well-defined and proper place.
    '';
    license = licenses.mit;
    homepage = "https://github.com/yshui/compton";
    maintainers = with maintainers; [ ertes enzime twey ];
    platforms = platforms.linux;
  };
}
