# Despite the name (and even --help message) this is a TUI -- not a CLI.
# There is no way to use tis non-interactively.
#
# first-run/config:
# - provision Kagi API key: <https://kagi.com/settings/api>
# - add API credits: <https://kagi.com/settings/billing_api>
#   - 1.5c/call (billed as $15 per 1000)
# - launch `fastgpt`, enter the API key.
#   this causes ~/.config/fastgpt/config.toml to be populated with your API key.
{
  fetchFromGitHub,
  gitUpdater,
  lib,
  rustPlatform,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kagi-fastgpt-cli";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "0xgingi";
    repo = "kagi-fastgpt-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PNgDLIilYGTK/OexnPfKJrTkglchnFlQlhn6J19gzA8=";
  };

  cargoHash = "sha256-f/yGzWF9/pnJLLZPGTSUY95WB81dp/mM3Dc1FPDAglc=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "A command-line interface for Kagi's FastGPT API written in Rust";
    longDescription = ''
      TUI for Kagi Assistant (FastGPT).
      Officially recommended by Kagi: <https://help.kagi.com/kagi/community-addons/#kagi-fastgpt-cli>
    '';
    homepage = "https://github.com/0xgingi/kagi-fastgpt-cli";
    license = lib.licenses.mit;
    mainProgram = "fastgpt";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
