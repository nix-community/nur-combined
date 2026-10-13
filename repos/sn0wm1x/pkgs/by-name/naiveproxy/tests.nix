{
  lib,
  runCommand,
  python3,
  openssl,
  curl,
  patch,
  caddy,
  naiveproxy,
}:
runCommand "naiveproxy-integration-tests"
  {
    nativeBuildInputs = [
      python3
      openssl
      curl
      patch
    ];
  }
  ''
    cp -r ${naiveproxy.src}/tests tests
    mkdir -p src/net/tools/quic
    cp -r ${naiveproxy.src}/src/net/tools/quic/certs src/net/tools/quic/certs
    chmod -R u+w tests
    # The upstream test still reads the pre-NDJSON NetLog event format.
    patch -p1 < ${./netlog-test.patch}
    python3 tests/ssl_cert_file.py \
      --naive=${lib.getExe naiveproxy} \
      --caddy=${lib.getExe caddy}
    touch "$out"
  ''
