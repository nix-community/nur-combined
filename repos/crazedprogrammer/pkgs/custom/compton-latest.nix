# This derivation will be removed when NixOS 19.03 releases.
{ stdenv, lib, fetchFromGitHub, pkgconfig, asciidoc, docbook_xml_dtd_45
, docbook_xsl, libxslt, libxml2, makeWrapper, meson, ninja
, xorg, libxcb ,xcbutilrenderutil, xcbutilimage, pixman, libev
, dbus, libconfig, libdrm, libGL, pcre, libX11, libXcomposite, libXdamage
, libXinerama, libXrandr, libXrender, libXext, xwininfo, libxdg_basedir
, xorgproto ? xorg.xproto }:

let
  common = source: stdenv.mkDerivation (source // rec {
    name = "${source.pname}-${source.version}";

    nativeBuildInputs = (source.nativeBuildInputs or []) ++ [
      pkgconfig
      asciidoc
      docbook_xml_dtd_45
      docbook_xsl
      makeWrapper
    ];

    installFlags = [ "PREFIX=$(out)" ];

    postInstall = ''
      wrapProgram $out/bin/compton-trans \
        --prefix PATH : ${lib.makeBinPath [ xwininfo ]}
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
      maintainers = with maintainers; [ ertes enzime twey ];
      platforms = platforms.linux;
    };
  });

  gitSource = rec {
    pname = "compton-git";
    version = "5.1";

    COMPTON_VERSION = "v${version}";

    nativeBuildInputs = [ meson ninja ];

    src = fetchFromGitHub {
      owner  = "yshui";
      repo   = "compton";
      rev    = COMPTON_VERSION;
      sha256 = "1qpy76kkhz8gfby842ry7lanvxkjxh4ckclkcjk4xi2wsmbhyp08";
    };

    buildInputs = [
      dbus libX11 libXext
      xorgproto
      libXinerama libdrm pcre libxml2 libxslt libconfig libGL
      # Removed:
      # libXcomposite libXdamage libXrender libXrandr

      # New:
      libxcb xcbutilrenderutil xcbutilimage
      pixman libev
      libxdg_basedir
    ];

    preBuild = ''
      git() { echo "v${version}"; }
      export -f git
    '';

    NIX_CFLAGS_COMPILE = [ "-fno-strict-aliasing" ];

    mesonFlags = [
      "-Dvsync_drm=true"
      "-Dnew_backends=true"
      "-Dbuild_docs=true"
    ];

    meta = {
      homepage = https://github.com/yshui/compton/;
    };
  };
in common gitSource
