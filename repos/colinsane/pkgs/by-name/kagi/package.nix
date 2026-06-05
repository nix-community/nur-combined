# config/setup:
# - set `KAGI_API_KEY=...` env var
# - OR, invoke with `--api-key $KEY` each time
#
{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "kagi";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "grantcarthew";
    repo = "kagi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LBht0Etg5XEDQPETxp+xmr7HT1qbAV4Ul1opi4KfK/k=";
  };
  proxyVendor = true;
  vendorHash = "sha256-RgGDapuL5gtviLBHv42jmcARRf6tBLmrlTpImNlr8mg=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A fast, simple command-line interface for Kagi FastGPT - AI-powered search with web context";
    longDescription = ''
    Features:
    - Simple Interface: Just type your query and get AI-powered answers
    - Multiple Output Formats: Plain text, Markdown, or JSON
    - Smart Color Output: Automatically detects terminals and pipes
    - Web References: Includes sources with every response
    - Flexible Input: Accept queries from arguments or stdin
    - AI Agent Friendly: Clean output formats for automation
    '';
    mainProgram = "kagi";
    homepage = "https://github.com/grantcarthew/kagi";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
