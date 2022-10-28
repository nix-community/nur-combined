{
  buildGoModule,
  olm,
  fetchFromGitHub,
  lib,
  writeScript,
  go,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  buildGoModule rec {
    pname = "mautrix-whatsapp";
    version = source.date;
    src = fetchFromGitHub {
      owner = "mautrix";
      repo = "whatsapp";
      inherit (source) rev sha256;
    };
    vendorSha256 = builtins.readFile ./vendor.sha256;
    buildInputs = [
      olm
    ];
    proxyVendor = true;
    CGO_ENABLED = "1";
    meta = {
      description = "Whatsapp-Matrix double-puppeting bridge";
      license = lib.licenses.agpl3;
      broken = builtins.compareVersions go.version "1.18" < 0;
    };
    passthru.updateScript = writeScript "update-mautrix-whatsapp" ''
      ${../../scripts/update-git.sh} "https://github.com/mautrix/whatsapp" matrix/mautrix-whatsapp/source.json
      SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
      ${../../scripts/update-go.sh} ./matrix/mautrix-whatsapp matrix/mautrix-whatsapp/vendor.sha256
    '';
  }
