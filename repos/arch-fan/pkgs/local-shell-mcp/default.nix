{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "local-shell-mcp";
  version = "4.3.2";

  src = fetchurl {
    url =
      "https://github.com/fwerkor/local-shell-mcp/releases/download/"
      + "v${finalAttrs.version}/local-shell-mcp-linux-x86_64.tar.gz";
    hash = "sha256-2fIXehW1xw5ZsNP0QAlgwNRYvEsw9yl7TmKWXlboxR8=";
  };

  sourceRoot = "local-shell-mcp-linux-x86_64";

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 local-shell-mcp $out/bin/local-shell-mcp

    runHook postInstall
  '';

  meta = {
    description = "Enables LLM to use a cli environment";
    homepage = "https://github.com/fwerkor/local-shell-mcp";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "local-shell-mcp";
  };
})
