{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  stdenv,
  pkg-config,
  glib,
  openssl,
  libevent,
  pcre2,
  json-glib,
  libwebsockets,
  libnftnl,
  libmnl,
  iptables,
  ffmpeg,
  spandsp,
  libopus,
  libpcap,
  hiredis,
  xmlrpc_c,
  libmysqlclient,
  perl,
  libxml2,
  gperf,
  pandoc,
  ncurses,
  libjwt,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rtpengine";
  version = "0-unstable-2026-10-16";
  src = fetchFromGitHub {
    owner = "sipwise";
    repo = "rtpengine";
    rev = "e1e886ee4fd3af3dd0c980696bb7c77278376419";
    hash = "sha256-LZUwGYq3XHJrVbwC/oa1nUYNOFrkV3Obr5A0DsJVjQo=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  enableParallelBuilding = true;

  nativeBuildInputs = [
    pkg-config
    perl
    gperf
    pandoc
  ];
  buildInputs = [
    glib
    openssl
    libevent
    pcre2
    json-glib
    libwebsockets
    libnftnl
    libmnl
    iptables
    ffmpeg
    spandsp
    libopus
    libpcap
    hiredis
    xmlrpc_c
    libmysqlclient
    libxml2
    ncurses
    libjwt
  ];

  postPatch = ''
    patchShebangs .
  '';

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  postInstall = ''
    mv $out/usr/* $out/
    rm -rf $out/usr
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/sipwise/rtpengine";
    tagPrefix = "mr";
    shallowClone = false;
  };
  meta = {
    changelog = "https://github.com/sipwise/rtpengine/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Sipwise media proxy for Kamailio";
    homepage = "https://github.com/sipwise/rtpengine";
    license = lib.licenses.gpl3Only;
    mainProgram = "rtpengine";
  };
})
