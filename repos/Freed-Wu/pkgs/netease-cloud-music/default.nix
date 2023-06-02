{ lib
, stdenv
, fetchurl
, dpkg
, rsync
, autoPatchelfHook
, xorg
, libdrm
, alsa-lib
, taglib
, vlc
, krb5
, gtk2
, gtk3
, tcp_wrappers
, e2fsprogs
, gnutls
, avahi
, sqlite
, libogg
, libvorbis
, libsndfile
, libasyncns
, dbus-glib
, cups
, nspr
, gnome2
, nss
, icu60
, libinput
, mtdev
  # , double-conversion
, libpulseaudio
  # , libjpeg_original
  # , nettle
  # , flac
}:
stdenv.mkDerivation rec {
  pname = "netease-cloud-music";
  version = "1.2.1";

  src = fetchurl {
    url = "https://d1.music.126.net/dmusic/netease-cloud-music_1.2.1_amd64_ubuntu_20190428.deb";
    sha256 = "sha256-HunwKELmwsjHnEiy6TIHT5whOo60I45eY/IEOFYv7Ls=";
    curlOptsList = [ "-HUser-Agent: Wget/1.21.4" ];
  };

  # some libraries' versions don't match
  nativeBuildInputs = [
    dpkg
    rsync
    autoPatchelfHook
    stdenv.cc.cc.lib
    xorg.xcbutilkeysyms
    xorg.libXScrnSaver
    xorg.xcbutilimage
    xorg.xcbutilwm
    xorg.xcbutilrenderutil
    # xorg.libXtst
    libdrm
    alsa-lib
    taglib
    vlc
    krb5
    gtk2
    gtk3
    tcp_wrappers
    e2fsprogs
    gnutls
    avahi
    sqlite
    libogg
    libvorbis
    libsndfile
    libasyncns
    dbus-glib
    cups
    nspr
    gnome2.GConf
    nss
    icu60
    libinput
    mtdev
    # double-conversion
    libpulseaudio
    # libjpeg_original
    # nettle
    # flac
  ];

  dontBuild = true;
  # https://aur.archlinux.org/cgit/aur.git/tree/exclude.list?h=netease-cloud-music
  unpackPhase = ''
    dpkg -x "$src" .
    rm opt/netease/netease-cloud-music/libs/libgmodule-2.0.so.0
    rm opt/netease/netease-cloud-music/libs/libpango-1.0.so.0

    rm opt/netease/netease-cloud-music/libs/libgtk-3.so.0
    rm opt/netease/netease-cloud-music/libs/libgdk-3.so.0
    rm opt/netease/netease-cloud-music/libs/libXau.so.6
    rm opt/netease/netease-cloud-music/libs/libXcomposite.so.1
    rm opt/netease/netease-cloud-music/libs/libXcursor.so.1
    rm opt/netease/netease-cloud-music/libs/libXdamage.so.1
    rm opt/netease/netease-cloud-music/libs/libXdmcp.so.6
    rm opt/netease/netease-cloud-music/libs/libXext.so.6
    rm opt/netease/netease-cloud-music/libs/libXfixes.so.3
    rm opt/netease/netease-cloud-music/libs/libXi.so.6
    rm opt/netease/netease-cloud-music/libs/libXinerama.so.1
    rm opt/netease/netease-cloud-music/libs/libXrandr.so.2
    rm opt/netease/netease-cloud-music/libs/libXrender.so.1
    rm opt/netease/netease-cloud-music/libs/libatk-1.0.so.0
    rm opt/netease/netease-cloud-music/libs/libatk-bridge-2.0.so.0
    rm opt/netease/netease-cloud-music/libs/libatspi.so.0
    rm opt/netease/netease-cloud-music/libs/libblkid.so.1
    rm opt/netease/netease-cloud-music/libs/libbz2.so.1.0
    rm opt/netease/netease-cloud-music/libs/libcairo-gobject.so.2
    rm opt/netease/netease-cloud-music/libs/libcairo.so.2
    rm opt/netease/netease-cloud-music/libs/libcap.so.2
    rm opt/netease/netease-cloud-music/libs/libdatrie.so.1
    rm opt/netease/netease-cloud-music/libs/libdbus-1.so.3
    rm opt/netease/netease-cloud-music/libs/libepoxy.so.0
    rm opt/netease/netease-cloud-music/libs/libfribidi.so.0
    rm opt/netease/netease-cloud-music/libs/libgcrypt.so.20
    rm opt/netease/netease-cloud-music/libs/libgdk-x11-2.0.so.0
    rm opt/netease/netease-cloud-music/libs/libgraphite2.so.3
    rm opt/netease/netease-cloud-music/libs/libgtk-x11-2.0.so.0
    # rm opt/netease/netease-cloud-music/libs/libjpeg.so.8
    rm opt/netease/netease-cloud-music/libs/liblz4.so.1
    rm opt/netease/netease-cloud-music/libs/liblzma.so.5
    rm opt/netease/netease-cloud-music/libs/libmount.so.1
    rm opt/netease/netease-cloud-music/libs/libpangoft2-1.0.so.0
    rm opt/netease/netease-cloud-music/libs/libpixman-1.so.0
    rm opt/netease/netease-cloud-music/libs/libpng16.so.16
    rm opt/netease/netease-cloud-music/libs/libsystemd.so.0
    rm opt/netease/netease-cloud-music/libs/libtiff.so.5
    rm opt/netease/netease-cloud-music/libs/libwayland-client.so.0
    rm opt/netease/netease-cloud-music/libs/libwayland-cursor.so.0
    rm opt/netease/netease-cloud-music/libs/libwayland-egl.so.1
    rm opt/netease/netease-cloud-music/libs/libxcb-render.so.0
    rm opt/netease/netease-cloud-music/libs/libxcb-shm.so.0
    rm opt/netease/netease-cloud-music/libs/libxkbcommon.so.0
    rm opt/netease/netease-cloud-music/libs/libxkbcommon-x11.so.0

    rm opt/netease/netease-cloud-music/libs/libopenmpt_modplug.so.1
    rm opt/netease/netease-cloud-music/libs/libplacebo.so.4
    rm opt/netease/netease-cloud-music/libs/libpostproc.so.54
    rm opt/netease/netease-cloud-music/libs/libprotobuf-lite.so.10
    rm opt/netease/netease-cloud-music/libs/libresid-builder.so.0
    rm opt/netease/netease-cloud-music/libs/libshine.so.3
    rm opt/netease/netease-cloud-music/libs/libsidplay2.so.1
    rm opt/netease/netease-cloud-music/libs/libsndio.so.6.1
    rm opt/netease/netease-cloud-music/libs/libswscale.so.4
    rm opt/netease/netease-cloud-music/libs/libupnp.so.6
    rm opt/netease/netease-cloud-music/libs/libvlc.so.5
    rm opt/netease/netease-cloud-music/libs/libvlc_pulse.so.0
    rm opt/netease/netease-cloud-music/libs/libvlc_vdpau.so.0
    rm opt/netease/netease-cloud-music/libs/libvlc_xcb_events.so.0
    rm opt/netease/netease-cloud-music/libs/libvlccore.so.9
    rm opt/netease/netease-cloud-music/libs/libx264.so.152
    rm opt/netease/netease-cloud-music/libs/libx265.so.146
    rm -r opt/netease/netease-cloud-music/libs/vlc

    rm opt/netease/netease-cloud-music/libs/libselinux.so.1
    rm opt/netease/netease-cloud-music/libs/liblibcli-lsa3.so.0
    rm opt/netease/netease-cloud-music/libs/libmessages-dgm.so.0
    rm opt/netease/netease-cloud-music/libs/libhcrypto.so.4
    rm opt/netease/netease-cloud-music/libs/libjbig.so.0
    rm opt/netease/netease-cloud-music/libs/libndr-samba.so.0
    # rm opt/netease/netease-cloud-music/libs/libhogweed.so.4
    rm opt/netease/netease-cloud-music/libs/libcli-smb-common.so.0
    rm opt/netease/netease-cloud-music/libs/libreplace.so.0
    rm opt/netease/netease-cloud-music/libs/libsecrets3.so.0
    rm opt/netease/netease-cloud-music/libs/libnuma.so.1
    rm opt/netease/netease-cloud-music/libs/libtalloc-report.so.0
    rm opt/netease/netease-cloud-music/libs/libffi.so.6
    rm opt/netease/netease-cloud-music/libs/liblibsmb.so.0
    rm opt/netease/netease-cloud-music/libs/libwebp.so.6
    rm opt/netease/netease-cloud-music/libs/libsamba-security.so.0
    rm opt/netease/netease-cloud-music/libs/libvorbisfile.so.3
    rm opt/netease/netease-cloud-music/libs/libcli-nbt.so.0
    rm opt/netease/netease-cloud-music/libs/libwavpack.so.1
    rm opt/netease/netease-cloud-music/libs/libasn1.so.8
    rm opt/netease/netease-cloud-music/libs/libaddns.so.0
    rm opt/netease/netease-cloud-music/libs/libutil-setid.so.0
    rm opt/netease/netease-cloud-music/libs/libmsrpc3.so.0
    rm opt/netease/netease-cloud-music/libs/libgenrand.so.0
    rm opt/netease/netease-cloud-music/libs/libasn1util.so.0
    rm opt/netease/netease-cloud-music/libs/libsasl2.so.2
    rm opt/netease/netease-cloud-music/libs/libldbsamba.so.0
    rm opt/netease/netease-cloud-music/libs/libwinbind-client.so.0
    rm opt/netease/netease-cloud-music/libs/libgssapi.so.3
    rm opt/netease/netease-cloud-music/libs/libslang.so.2
    rm opt/netease/netease-cloud-music/libs/libiov-buf.so.0
    rm opt/netease/netease-cloud-music/libs/libssh-gcrypt.so.4
    rm opt/netease/netease-cloud-music/libs/libsamba-credentials.so.0
    rm opt/netease/netease-cloud-music/libs/libutil-tdb.so.0
    rm opt/netease/netease-cloud-music/libs/libvpx.so.5
    rm opt/netease/netease-cloud-music/libs/libcroco-0.6.so.3
    rm opt/netease/netease-cloud-music/libs/libauthkrb5.so.0
    rm opt/netease/netease-cloud-music/libs/libsamba-sockets.so.0
    rm opt/netease/netease-cloud-music/libs/libcli-cldap.so.0
    rm opt/netease/netease-cloud-music/libs/libCHARSET3.so.0
    rm opt/netease/netease-cloud-music/libs/libutil-reg.so.0
    rm opt/netease/netease-cloud-music/libs/libcommon-auth.so.0
    rm opt/netease/netease-cloud-music/libs/libutil-cmdline.so.0
    # rm opt/netease/netease-cloud-music/libs/libnettle.so.6
    rm opt/netease/netease-cloud-music/libs/libattr.so.1
    rm opt/netease/netease-cloud-music/libs/libsamdb-common.so.0
    rm opt/netease/netease-cloud-music/libs/libsys-rw.so.0
    rm opt/netease/netease-cloud-music/libs/liblzo2.so.2
    rm opt/netease/netease-cloud-music/libs/libncursesw.so.5
    rm opt/netease/netease-cloud-music/libs/libheimntlm.so.0
    rm opt/netease/netease-cloud-music/libs/libmsghdr.so.0
    rm opt/netease/netease-cloud-music/libs/libsamba-modules.so.0
    rm opt/netease/netease-cloud-music/libs/libtdb-wrap.so.0
    rm opt/netease/netease-cloud-music/libs/libwrap.so.0
    rm opt/netease/netease-cloud-music/libs/libndr.so.0
    rm opt/netease/netease-cloud-music/libs/libdbwrap.so.0
    # rm opt/netease/netease-cloud-music/libs/libpulsecommon-11.1.so
    rm opt/netease/netease-cloud-music/libs/libkrb5.so.26
    rm opt/netease/netease-cloud-music/libs/libsnappy.so.1
    rm opt/netease/netease-cloud-music/libs/libpulse-simple.so.0
    rm -r opt/netease/netease-cloud-music/libs/nss
    rm opt/netease/netease-cloud-music/libs/libcli-ldap-common.so.0
    rm opt/netease/netease-cloud-music/libs/libpcre.so.3
    rm opt/netease/netease-cloud-music/libs/libroken.so.18
    rm opt/netease/netease-cloud-music/libs/libserver-id-db.so.0
    rm opt/netease/netease-cloud-music/libs/libhx509.so.5
    rm opt/netease/netease-cloud-music/libs/libthreadutil.so.6
    rm opt/netease/netease-cloud-music/libs/libsamba-debug.so.0
    rm opt/netease/netease-cloud-music/libs/libgme.so.0
    rm opt/netease/netease-cloud-music/libs/libheimbase.so.1
    rm opt/netease/netease-cloud-music/libs/libsmb-transport.so.0
    rm opt/netease/netease-cloud-music/libs/libsamba3-util.so.0
    rm opt/netease/netease-cloud-music/libs/libswresample.so.2
    rm opt/netease/netease-cloud-music/libs/libdcerpc-samba.so.0
    rm opt/netease/netease-cloud-music/libs/libgensec.so.0
    rm opt/netease/netease-cloud-music/libs/libwind.so.0
    rm opt/netease/netease-cloud-music/libs/libMESSAGING-SEND.so.0
    rm opt/netease/netease-cloud-music/libs/libserver-role.so.0
    rm opt/netease/netease-cloud-music/libs/libtinfo.so.5
    rm opt/netease/netease-cloud-music/libs/libsocket-blocking.so.0
    rm opt/netease/netease-cloud-music/libs/libncurses.so.5
    rm opt/netease/netease-cloud-music/libs/libgse.so.0
    rm opt/netease/netease-cloud-music/libs/libmessages-util.so.0
    rm opt/netease/netease-cloud-music/libs/libcliauth.so.0
    rm opt/netease/netease-cloud-music/libs/libsmbd-shim.so.0
    rm opt/netease/netease-cloud-music/libs/libldap_r-2.4.so.2
    rm opt/netease/netease-cloud-music/libs/libkrb5samba.so.0
    rm opt/netease/netease-cloud-music/libs/libinterfaces.so.0
    rm opt/netease/netease-cloud-music/libs/libXpm.so.4
    rm opt/netease/netease-cloud-music/libs/libflag-mapping.so.0
    rm opt/netease/netease-cloud-music/libs/libopenmpt.so.0
    rm opt/netease/netease-cloud-music/libs/libtime-basic.so.0
    rm opt/netease/netease-cloud-music/libs/libldb.so.1
    rm opt/netease/netease-cloud-music/libs/libvulkan.so.1

    rm opt/netease/netease-cloud-music/libs/libSDL_image-1.2.so.0
    rm opt/netease/netease-cloud-music/libs/libaa.so.1
    rm opt/netease/netease-cloud-music/libs/libarchive.so.13
    rm opt/netease/netease-cloud-music/libs/libavcodec.so.57
    rm opt/netease/netease-cloud-music/libs/libavformat.so.57
    rm opt/netease/netease-cloud-music/libs/libcaca.so.0
    rm opt/netease/netease-cloud-music/libs/libdcerpc-binding.so.0
    rm opt/netease/netease-cloud-music/libs/libkrb5-samba4.so.26
    rm opt/netease/netease-cloud-music/libs/libmtp.so.9
    rm opt/netease/netease-cloud-music/libs/libndr-krb5pac.so.0
    rm opt/netease/netease-cloud-music/libs/libndr-nbt.so.0
    rm opt/netease/netease-cloud-music/libs/libndr-standard.so.0
    rm opt/netease/netease-cloud-music/libs/librsvg-2.so.2
    rm opt/netease/netease-cloud-music/libs/libsamba-hostconfig.so.0
    rm opt/netease/netease-cloud-music/libs/libsamba-util.so.0
    rm opt/netease/netease-cloud-music/libs/libsamdb.so.0
    rm opt/netease/netease-cloud-music/libs/libsecret-1.so.0
    rm opt/netease/netease-cloud-music/libs/libsmbclient.so.0
    rm opt/netease/netease-cloud-music/libs/libsmbconf.so.0
    rm opt/netease/netease-cloud-music/libs/libssh2.so.1
    rm opt/netease/netease-cloud-music/libs/libwbclient.so.0
    rm opt/netease/netease-cloud-music/libs/libwebpmux.so.3
    rm opt/netease/netease-cloud-music/libs/libSDL-1.2.so.0
    rm opt/netease/netease-cloud-music/libs/libchromaprint.so.1
    rm opt/netease/netease-cloud-music/libs/libgssapi-samba4.so.2
    rm opt/netease/netease-cloud-music/libs/libdc1394.so.22
    rm opt/netease/netease-cloud-music/libs/libgnutls.so.30
    rm opt/netease/netease-cloud-music/libs/libgssapi_krb5.so.2
    rm opt/netease/netease-cloud-music/libs/libacl.so.1
    rm opt/netease/netease-cloud-music/libs/libavahi-client.so.3
    rm opt/netease/netease-cloud-music/libs/libavahi-common.so.3
    rm opt/netease/netease-cloud-music/libs/libsqlite3.so.0
    rm opt/netease/netease-cloud-music/libs/libtag.so.1
    rm opt/netease/netease-cloud-music/libs/libogg.so.0
    rm opt/netease/netease-cloud-music/libs/libvorbis.so.0
    rm opt/netease/netease-cloud-music/libs/libvorbisenc.so.2
    rm opt/netease/netease-cloud-music/libs/libsndfile.so.1
    rm opt/netease/netease-cloud-music/libs/libasyncns.so.0
    rm opt/netease/netease-cloud-music/libs/libdbus-glib-1.so.2
    rm opt/netease/netease-cloud-music/libs/libcups.so.2
    rm opt/netease/netease-cloud-music/libs/libnspr4.so
    rm opt/netease/netease-cloud-music/libs/libplc4.so
    rm opt/netease/netease-cloud-music/libs/libplds4.so
    rm opt/netease/netease-cloud-music/libs/libgconf-2.so.4
    rm opt/netease/netease-cloud-music/libs/libnssutil3.so
    rm opt/netease/netease-cloud-music/libs/libnss3.so
    rm opt/netease/netease-cloud-music/libs/libXss.so.1
    rm opt/netease/netease-cloud-music/libs/libicudata.so.60
    rm opt/netease/netease-cloud-music/libs/libicuuc.so.60
    rm opt/netease/netease-cloud-music/libs/libicui18n.so.60
    rm opt/netease/netease-cloud-music/libs/libX11-xcb.so.1
    rm opt/netease/netease-cloud-music/libs/libxcb-*
    rm opt/netease/netease-cloud-music/libs/libtevent.so.0
    rm opt/netease/netease-cloud-music/libs/libshout.so.3
    rm opt/netease/netease-cloud-music/libs/libssl.so.1.1
    rm opt/netease/netease-cloud-music/libs/libtevent-util.so.0
    rm opt/netease/netease-cloud-music/libs/libwind-samba4.so.0
    rm opt/netease/netease-cloud-music/libs/libroken-samba4.so.19
    rm opt/netease/netease-cloud-music/libs/liba52-0.7.4.so
    rm opt/netease/netease-cloud-music/libs/libaribb24.so.0
    rm opt/netease/netease-cloud-music/libs/libasn1-samba4.so.8
    rm opt/netease/netease-cloud-music/libs/libass.so.9
    rm opt/netease/netease-cloud-music/libs/libavc1394.so.0
    rm opt/netease/netease-cloud-music/libs/libavutil.so.55
    rm opt/netease/netease-cloud-music/libs/libBasicUsageEnvironment.so.1
    rm opt/netease/netease-cloud-music/libs/libbluray.so.2
    rm opt/netease/netease-cloud-music/libs/libbsd.so.0
    rm opt/netease/netease-cloud-music/libs/libcddb.so.2
    rm opt/netease/netease-cloud-music/libs/libcom_err-samba4.so.0
    rm opt/netease/netease-cloud-music/libs/libcrypto.so.1.1
    rm opt/netease/netease-cloud-music/libs/libcrystalhd.so.3
    rm opt/netease/netease-cloud-music/libs/libdca.so.0
    # rm opt/netease/netease-cloud-music/libs/libdouble-conversion.so.1
    rm opt/netease/netease-cloud-music/libs/libdvbpsi.so.10
    rm opt/netease/netease-cloud-music/libs/libdvdnav.so.4
    rm opt/netease/netease-cloud-music/libs/libdvdread.so.4
    rm opt/netease/netease-cloud-music/libs/libebml.so.4
    rm opt/netease/netease-cloud-music/libs/libEGL.so.1
    rm opt/netease/netease-cloud-music/libs/libevdev.so.2
    rm opt/netease/netease-cloud-music/libs/libfaad.so.2
    # rm opt/netease/netease-cloud-music/libs/libFLAC.so.8
    rm opt/netease/netease-cloud-music/libs/libGLdispatch.so.0
    rm opt/netease/netease-cloud-music/libs/libGLESv2.so.2
    rm opt/netease/netease-cloud-music/libs/libGLX.so.0
    rm opt/netease/netease-cloud-music/libs/libgmp.so.10
    rm opt/netease/netease-cloud-music/libs/libgomp.so.1
    rm opt/netease/netease-cloud-music/libs/libgpm.so.2
    rm opt/netease/netease-cloud-music/libs/libgroupsock.so.8
    rm opt/netease/netease-cloud-music/libs/libgsm.so.1
    rm opt/netease/netease-cloud-music/libs/libgudev-1.0.so.0
    rm opt/netease/netease-cloud-music/libs/libhcrypto-samba4.so.5
    rm opt/netease/netease-cloud-music/libs/libheimbase-samba4.so.1
    rm opt/netease/netease-cloud-music/libs/libhogweed.so.4
    rm opt/netease/netease-cloud-music/libs/libhx509-samba4.so.5
    rm opt/netease/netease-cloud-music/libs/libidn2.so.0
    rm opt/netease/netease-cloud-music/libs/libidn.so.11
    rm opt/netease/netease-cloud-music/libs/libinput.so.10
    rm opt/netease/netease-cloud-music/libs/libixml.so.2
    rm opt/netease/netease-cloud-music/libs/libjansson.so.4
    # rm opt/netease/netease-cloud-music/libs/libjpeg.so.8
    rm opt/netease/netease-cloud-music/libs/libk5crypto.so.3
    rm opt/netease/netease-cloud-music/libs/libkate.so.1
    rm opt/netease/netease-cloud-music/libs/libkrb5.so.3
    rm opt/netease/netease-cloud-music/libs/libkrb5support.so.0
    rm opt/netease/netease-cloud-music/libs/liblber-2.4.so.2
    rm opt/netease/netease-cloud-music/libs/liblirc_client.so.0
    rm opt/netease/netease-cloud-music/libs/libliveMedia.so.62
    rm opt/netease/netease-cloud-music/libs/liblua5.2.so.0
    rm opt/netease/netease-cloud-music/libs/libmad.so.0
    rm opt/netease/netease-cloud-music/libs/libmatroska.so.6
    rm opt/netease/netease-cloud-music/libs/libmicrodns.so.0
    rm opt/netease/netease-cloud-music/libs/libmp3lame.so.0
    rm opt/netease/netease-cloud-music/libs/libmpcdec.so.6
    rm opt/netease/netease-cloud-music/libs/libmpeg2.so.0
    rm opt/netease/netease-cloud-music/libs/libmpg123.so.0
    rm opt/netease/netease-cloud-music/libs/libmtdev.so.1
    rm opt/netease/netease-cloud-music/libs/libnettle.so.6
    rm opt/netease/netease-cloud-music/libs/libnfs.so.11
    rm opt/netease/netease-cloud-music/libs/libnotify.so.4
    rm opt/netease/netease-cloud-music/libs/libopenjp2.so.7
    rm opt/netease/netease-cloud-music/libs/libopus.so.0
    rm opt/netease/netease-cloud-music/libs/libpulse.so.0
    # rm opt/netease/netease-cloud-music/libs/libqcef.so.1
    # rm opt/netease/netease-cloud-music/libs/libqcef.so.1.1.4
    # rm opt/netease/netease-cloud-music/libs/libQt5Core.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5DBus.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5EglFSDeviceIntegration.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5Gui.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5Network.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5Qml.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5Svg.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5WebChannel.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5Widgets.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5X11Extras.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5XcbQpa.so.5
    # rm opt/netease/netease-cloud-music/libs/libQt5Xml.so.5
    rm opt/netease/netease-cloud-music/libs/libraw1394.so.11
    rm opt/netease/netease-cloud-music/libs/librom1394.so.0
    rm opt/netease/netease-cloud-music/libs/libsamba-errors.so.1
    rm opt/netease/netease-cloud-music/libs/libsamplerate.so.0
    rm opt/netease/netease-cloud-music/libs/libsmime3.so
    rm opt/netease/netease-cloud-music/libs/libsoxr.so.0
    rm opt/netease/netease-cloud-music/libs/libspeexdsp.so.1
    rm opt/netease/netease-cloud-music/libs/libspeex.so.1
    rm opt/netease/netease-cloud-music/libs/libtalloc.so.2
    rm opt/netease/netease-cloud-music/libs/libtasn1.so.6
    rm opt/netease/netease-cloud-music/libs/libva-drm.so.2
    rm opt/netease/netease-cloud-music/libs/libva.so.2
    rm opt/netease/netease-cloud-music/libs/libva-wayland.so.2
    rm opt/netease/netease-cloud-music/libs/libva-x11.so.2
    rm opt/netease/netease-cloud-music/libs/libvdpau.so.1
    rm opt/netease/netease-cloud-music/libs/libwacom.so.2
    rm opt/netease/netease-cloud-music/libs/libxml2.so.2
    rm opt/netease/netease-cloud-music/libs/libunistring.so.2
    rm opt/netease/netease-cloud-music/libs/libUsageEnvironment.so.3
    rm opt/netease/netease-cloud-music/libs/libxvidcore.so.4
    rm opt/netease/netease-cloud-music/libs/libzvbi.so.0
    rm opt/netease/netease-cloud-music/libs/libtdb.so.1
    rm opt/netease/netease-cloud-music/libs/libtheoradec.so.1
    rm opt/netease/netease-cloud-music/libs/libtheoraenc.so.1
    rm opt/netease/netease-cloud-music/libs/libtwolame.so.0
    rm opt/netease/netease-cloud-music/libs/libtheora.so.0
    # rm opt/netease/netease-cloud-music/libs/libudev.so.1
    # rm opt/netease/netease-cloud-music/libs/libXtst.so.6

  '';

  installPhase = ''
    rsync -rv usr/ "$out"
    rsync -rv opt/netease/ "$out" \
      --exclude netease-cloud-music/netease-cloud-music.bash \
      --exclude netease-cloud-music/plugins/platforms
    rsync -rv "opt/netease/netease-cloud-music/plugins/platforms" "$out/netease-cloud-music"
    rsync -v "opt/netease/netease-cloud-music/netease-cloud-music.bash" "$out/bin/netease-cloud-music"
    sed -i 2,5d "$out/bin/netease-cloud-music"
    sed -i "2iHERE='$out/netease-cloud-music'" "$out/bin/netease-cloud-music"
    ln -s libqcef.so.1.1.4 "$out/netease-cloud-music/libs/libqcef.so.1"
  '';

  meta = with lib; {
    mainProgram = "netease-cloud-music";
    homepage = "https://music.163.com";
    description = "Netease Cloud Music";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
