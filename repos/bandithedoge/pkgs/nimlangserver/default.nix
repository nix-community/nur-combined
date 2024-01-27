{
  pkgs,
  sources,
  ...
}:
pkgs.buildNimPackage {
  inherit (sources.nimlangserver) pname src;
  version = sources.nimlangserver.date;

  buildInputs = with sources; [
    asynctools.src
    chronicles.src
    faststreams.src
    json-rpc.src
    json_serialization.src
    serialization.src
    stew.src
    zevv-with.src
  ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = "The Nim language server implementation (based on nimsuggest)";
    homepage = "https://github.com/nim-lang/langserver";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
