{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.6.10";

  src =
    if stdenv.isx86_64 then
      fetchurl {
        url = "https://github.com/songquanpeng/one-api/releases/download/v${version}/one-api";
        hash = "sha256-6JH/fJUC7PHf6cAgYqLJRShqBbARNOhXwjQ9fw2yyhg=";
      }
    else if stdenv.isAarch64 then
      fetchurl {
        url = "https://github.com/songquanpeng/one-api/releases/download/v${version}/one-api-arm64";
        hash = "sha256-5E9njP0VdY2dYfN7OuXeZiF/TLilUYI8PIZ8c7CodjM=";
      }
    else
      throw "Unsupported architecture";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "one-api";
  inherit version src;

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/one-api

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenAI key management & redistribution system, using a single API for all LLMs";
    homepage = "https://openai.justsong.cn";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "one-api";
    knownVulnerabilities = [
      "No upstream updates for over a year, consider switching to new-api"
    ];
  };
})
