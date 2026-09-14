{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-sathi-ai";
  version = "2025.01.07-unstable-2026-08-05";

  src = fetchFromGitHub {
    owner = "ss44";
    repo = "sathi.ai";
    rev = "1d656040fb2a4a08656ac9bcd4df2dc859456e99";
    hash = "sha256-xz/cgiQEypzRG54+fWkrIocB+40DWbWaRawGqWwcqA4=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell simple multi-model AI chat widget usable with Ollama, Gemini, or OpenAI models (keys not included)";
    homepage = "https://github.com/ss44/sathi.ai";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
