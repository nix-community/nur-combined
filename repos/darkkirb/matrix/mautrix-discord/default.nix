{
  buildGoModule,
  olm,
  fetchFromGitHub,
  lib,
  writeScript,
}: let
  source = builtins.fromJSON (builtins.readFile ./source.json);
in
  buildGoModule rec {
    pname = "mautrix-discord";
    version = source.date;
    src = fetchFromGitHub {
      owner = "mautrix";
      repo = "discord";
      inherit (source) rev sha256;
    };
    patches = [./sticker.patch];
    vendorSha256 = builtins.readFile ./vendor.sha256;
    buildInputs = [
      olm
    ];
    proxyVendor = true;
    CGO_ENABLED = "1";
    meta = {
      description = "Discord-Matrix double-puppeting bridge";
      license = lib.licenses.agpl3;
    };
    passthru.updateScript = writeScript "update-matrix-media-repo" ''
      ${../../scripts/update-git.sh} "https://github.com/mautrix/discord" matrix/mautrix-discord/source.json
      SRC_PATH=$(nix-build -E '(import ./. {}).${pname}.src')
      ${../../scripts/update-go.sh} ./matrix/mautrix-discord matrix/mautrix-discord/vendor.sha256
    '';
  }
