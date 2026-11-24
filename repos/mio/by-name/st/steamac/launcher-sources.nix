{
  runCommand,
  fetchurl,
}:

# build.sh runs fetch-zstd.sh / fetch-enet.sh / fetch-nanors.sh, which download
# the pinned sources into the SwiftPM target directories. Vendor the same
# sources here so the Nix build stays offline.
let
  zstdVersion = "1.5.7";
  zstdHash = "sha256-6zPlH0mhXgI5UM14Jcp0pKK0Pbg1SCWsJPwbfuCeb6M=";

  enetCommit = "aca87840b57f045a1f7f9299e4b1b9b8e2a5e2f1";
  enetHash = "sha256-a7GhUebSHhdWuu/1qV6vhaW2cxrtptC8JVZRGSukoy0=";

  nanorsCommit = "a9b1636f9c98dbfdd0daeaf6982ccd24d1c30f29";
  nanorsHash = "sha256-yxKkWY1amfa8xGM7aE/ax6h8fWJ6gdmGCAhAxj/S2w8=";

  zstd = fetchurl {
    url = "https://github.com/facebook/zstd/releases/download/v${zstdVersion}/zstd-${zstdVersion}.tar.gz";
    hash = zstdHash;
  };

  enet = fetchurl {
    url = "https://github.com/cgutman/enet/archive/${enetCommit}.tar.gz";
    hash = enetHash;
  };

  nanors = fetchurl {
    url = "https://github.com/sleepybishop/nanors/archive/${nanorsCommit}.tar.gz";
    hash = nanorsHash;
  };
in
runCommand "steamac-launcher-sources" { } ''
  mkdir -p $out/CZstd/zstd $out/CEnet/enet $out/CEnet/include \
    $out/CNanors/nanors/deps

  tar -xzf ${zstd} -C $out/CZstd/zstd \
    zstd-${zstdVersion}/LICENSE zstd-${zstdVersion}/lib/zstd.h \
    zstd-${zstdVersion}/lib/zstd_errors.h zstd-${zstdVersion}/lib/common \
    zstd-${zstdVersion}/lib/decompress
  mv $out/CZstd/zstd/zstd-${zstdVersion}/lib/common $out/CZstd/zstd/zstd-${zstdVersion}/lib/decompress \
    $out/CZstd/zstd/zstd-${zstdVersion}/lib/zstd.h $out/CZstd/zstd/zstd-${zstdVersion}/lib/zstd_errors.h \
    $out/CZstd/zstd/
  mv $out/CZstd/zstd/zstd-${zstdVersion}/LICENSE $out/CZstd/zstd/
  rmdir $out/CZstd/zstd/zstd-${zstdVersion}/lib $out/CZstd/zstd/zstd-${zstdVersion}
  echo "${zstdVersion} ${zstdHash}" > $out/CZstd/zstd/VERSION

  mkdir -p enet-src nanors-src
  tar -xzf ${enet} -C enet-src --strip-components=1
  cp enet-src/LICENSE enet-src/callbacks.c enet-src/compress.c enet-src/host.c \
    enet-src/list.c enet-src/packet.c enet-src/peer.c enet-src/protocol.c enet-src/unix.c \
    $out/CEnet/enet/
  cp -R enet-src/include/enet $out/CEnet/include/enet
  echo "${enetCommit} ${enetHash}" > $out/CEnet/enet/VERSION

  tar -xzf ${nanors} -C nanors-src --strip-components=1
  cp nanors-src/LICENSE nanors-src/rs.c nanors-src/rs.h $out/CNanors/nanors/
  cp -R nanors-src/deps/obl $out/CNanors/nanors/deps/obl
  echo "${nanorsCommit} ${nanorsHash}" > $out/CNanors/nanors/VERSION
''
