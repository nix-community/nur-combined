{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go,
  olm,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "mautrix-telegram";
  # Upstream calls this release 26.10, but uses semver tags for Go modules.
  version = "0.2611.0";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "telegram";
    rev = "v${finalAttrs.version}";
    hash = "sha256-z3jfjQyh47scBjHNThLn5DluSSS4fT21NAibWyD5Iqc=";
  };

  vendorHash = "sha256-byvTXR7gy6b/TIVfJ8bwMC/D9vqn6iwjoxBE1gkBNBc=";

  subPackages = [ "cmd/mautrix-telegram" ];
  buildInputs = [ olm ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Tag=v${finalAttrs.version}"
  ];

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = finalAttrs.pname; };
  };

  meta = {
    description = "Matrix-Telegram puppeting bridge";
    homepage = "https://github.com/mautrix/telegram";
    changelog = "https://github.com/mautrix/telegram/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ yinfeng ];
    mainProgram = "mautrix-telegram";
    broken = lib.versionOlder go.version "1.26";
  };
})
