final: prev:
let
  inherit (prev) lib stdenv;

  # Bun 1.4.4 fixes the root certificate store: 1.4.3 and earlier still trust
  # the compromised emSign ECC Root CA - G3 (CVE-2026-111943). plannotator
  # embeds the Bun runtime in the binary it compiles, so it needs the fixed one.
  # nixpkgs still ships 1.4.2, so take the new version and hashes from the open
  # PR until it lands: https://github.com/NixOS/nixpkgs/pull/577354
  bunVersion = "1.4.4";

  releases = {
    "aarch64-darwin" = {
      file = "bun-darwin-aarch64.zip";
      hash = "sha256-wkDX8My5DCY6hJ/NsJt+5iYw2SE0jtaq/ahrnVd7xRA=";
    };
    "aarch64-linux" = {
      file = "bun-linux-aarch64.zip";
      hash = "sha256-uqa7NvUdblhWHgK76oJQOKnfRU9nPW13bou/hvjHhQ4=";
    };
    "x86_64-linux" = {
      file = "bun-linux-x64-baseline.zip";
      hash = "sha256-4ERutVmVdy65iUvrrppr42jZhai5Jx7hJEhvmUbu3XY=";
    };
  };

  release = releases.${stdenv.hostPlatform.system} or (throw "Bun ${bunVersion} is not available for ${stdenv.hostPlatform.system}");

  url = source: "https://github.com/oven-sh/bun/releases/download/bun-v${bunVersion}/${source.file}";
in
{
  bun =
    if lib.versionAtLeast (lib.getVersion prev.bun) bunVersion then
      prev.bun
    else
      prev.bun.overrideAttrs (old: {
        version = bunVersion;

        src = final.fetchurl {
          url = url release;
          hash = release.hash;
        };

        passthru = (builtins.removeAttrs old.passthru [ "updateScript" ]) // {
          sources = lib.mapAttrs (
            _: source:
            final.fetchurl {
              url = url source;
              hash = source.hash;
            }
          ) releases;
        };
      });
}
