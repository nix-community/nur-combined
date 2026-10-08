{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "local-shell-mcp";
  version = "5.1.1";

  src = fetchurl {
    url =
      "https://github.com/fwerkor/local-shell-mcp/releases/download/"
      + "v${finalAttrs.version}/local-shell-mcp-linux-x86_64.tar.gz";
    hash = "sha256-QCqFl9XNtByRGuNcfn2qf+w93UIyEF16bRy7YOmf50c=";
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
