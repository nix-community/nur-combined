{
  pkgs,
  sources,
  ...
}:
pkgs.buildNimPackage {
  inherit (sources.nimlangserver) pname src;
  version = sources.nimlangserver.date;

  buildInputs = with sources; [
    bearssl.src
    chronicles.src
    chronos.src
    faststreams.src
    httputils.src
    json-rpc.src
    json_serialization.src
    nimcrypto.src
    regex.src
    results.src
    serialization.src
    stew.src
    unicodedb.src
    websock.src
    zevv-with.src
    zlib.src
  ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "The Nim language server implementation (based on nimsuggest)";
    homepage = "https://github.com/nim-lang/langserver";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
