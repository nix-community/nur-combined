{
  callPackage,
  coreutils,
  curl,
  fetchFromGitHub,
  fetchurl,
  git,
  gnused,
  lib,
  nix-update-script,
  nodejs_22,
  stdenvNoCC,
  updater-tools,
  writeShellApplication,
}:
let
  version = "1.6.0-unstable-2026-11-22";
  src = fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "9c4652688590abb836b40ebd1e4725ecf9a7c7d1";
    hash = "sha256-R9uf5rOVqKNwEGZLZp97TjPFi8KT9kGDJt1aCG1dJPI=";
  };
  # Pin the latest published catalog separately: upstream's pin can lag behind main.
  modelCatalogHash = "dd93eb2741d05a80f41ffb94b5a1c1ccf33d2866d73292940251fd72584eb4bc";
  modelCatalogUrl = "https://pi.dev/api/models";
  modelCatalogQuery = "types=chat,image,classifier";
  modelCatalog = fetchurl {
    name = "pi-model-catalog.json";
    url = "${modelCatalogUrl}/revisions/sha256-${modelCatalogHash}?${modelCatalogQuery}";
    sha256 = modelCatalogHash;
  };
  pkg = callPackage "${src}/nix/package.nix" {
    source = src;
    fetchurl =
      args: if (args.name or "") == "pi-model-catalog.json" then modelCatalog else fetchurl args;
  };
  # Match the archive layout as used by nixpkgs `pi-coding-agent.modelData`, this to act as drop-in replacement.
  modelData = stdenvNoCC.mkDerivation {
    name = "pi-model-data-${version}.tgz";
    inherit src;
    nativeBuildInputs = [ nodejs_22 ];
    dontConfigure = true;
    buildPhase = ''
      runHook preBuild
      node packages/ai/scripts/hydrate-model-catalog.ts ${modelCatalog}
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p package/dist/providers
      mv packages/ai/src/providers/data package/dist/providers/
      tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner \
        --create --gzip --file="$out" package/dist/providers/data
      runHook postInstall
    '';
  };
  updateModelCatalog = writeShellApplication {
    name = "update-pi-model-catalog";
    runtimeInputs = [
      coreutils
      curl
      git
      gnused
    ];
    text = ''
      catalog_hash() {
        curl --fail --silent --show-error --location --max-time 60 "$1" | sha256sum | cut -d ' ' -f 1
      }
      hash=$(catalog_hash '${modelCatalogUrl}?${modelCatalogQuery}')
      if [[ $(catalog_hash "${modelCatalogUrl}/revisions/sha256-$hash?${modelCatalogQuery}") != "$hash" ]]; then
        echo "Pi model catalog revision sha256-$hash could not be verified" >&2
        exit 1
      fi

      root=$(git rev-parse --show-toplevel)
      sed -i -E "s/(modelCatalogHash = \")[0-9a-f]{64}(\";)/\1$hash\2/" \
        "$root/pkgs/by-name/pi-coding-agent-latest/package.nix"
    '';
  };
in
pkg.overrideAttrs (prevAttrs: {
  pname = "pi-coding-agent";
  inherit version src;
  # Keep src pointed at the checkout for nix-update, but install from its lockfile root.
  setSourceRoot = ''
    sourceRoot=(*/packages/coding-agent/install-lock)
  '';
  passthru = (prevAttrs.passthru or { }) // {
    inherit modelData;
    updateScript = updater-tools.requireAll [
      (nix-update-script { extraArgs = [ "--version=branch" ]; })
      [ (lib.getExe updateModelCatalog) ]
    ];
  };
})
