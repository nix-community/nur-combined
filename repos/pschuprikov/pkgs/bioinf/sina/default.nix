{ lib, stdenv, fetchFromGitHub, autoreconfHook, pkg-config, zlib, glib, boost, tbb, arbdb, arbcommon, arbcore, arbslhelix, arbprobe_com, arbaisc_com }:
stdenv.mkDerivation rec {
  version = "1.6.0";
  name = "sina-${version}";
  src = fetchFromGitHub {
    owner = "epruesse";
    repo = "SINA";
    rev = "a73f148d30c37c4c4540de336c89896ad762fe5f";
    sha256 = "sha256:0vm74az158p2w8pmi7wzyl2yvl2x3qv12xpggndqs9a3ixaakwba";
  };

  configureFlags = [ 
    "--with-boost-libdir=${boost.out}/lib"
    "--with-arbhome=${arbdb}"
    "--disable-docs"
  ];

  patchPhase = ''
    substituteInPlace m4/arb.m4 \
      --replace "INCLUDE" "include" \
      --replace "\$ARBHOME/SL/HELIX" "${arbslhelix}/lib"\
      --replace "\$ARBHOME/PROBE_COM" "${arbprobe_com}/lib"
  '';

  nativeBuildInputs = [ pkg-config autoreconfHook zlib glib boost tbb arbdb arbcommon arbcore arbslhelix arbprobe_com arbaisc_com ];

  installTargets = "install-exec";

  meta = {
    platforms = lib.platforms.linux;
    # due to missing libtirpc in CFLAGS
    broken = true;
  };
}
