{
  lib,
  stdenvNoCC,
  writeShellApplication,
  makeSetupHook,
  jq,
  agentPluginsJoin,
}:
let
  addMarketplace =
    {
      marketplaceFile,
      marketplaceData,
    }:
    fnOrAttrs: finalAttrs:
    let
      attrs = if lib.isFunction fnOrAttrs then fnOrAttrs finalAttrs else fnOrAttrs;
      finalPackage = finalAttrs.finalPackage;

    in
    attrs
    // {
      passthru = (attrs.passthru or { }) // {
        marketplace = marketplaceData;
        fetch-marketplace =
          let
            pname = finalAttrs.pname or finalPackage.name;
            src = finalAttrs.src;

            defaultMarketplaceFile =
              # Wire in the marketplace file such that running the script with no args
              # runs it against the correct marketplace file by default.
              # Note that toString is necessary here as it results in the path at
              # eval time (i.e. to the file in your local Nixpkgs checkout) rather
              # than the Nix store path of the path after it's been imported.
              if lib.isPath marketplaceFile && !lib.isStorePath marketplaceFile then
                toString marketplaceFile
              else
                ''$(mktemp -t "${finalAttrs.pname or finalPackage.name}-marketplace-XXXXXX.nix")'';
          in
          writeShellApplication {
            name = "${pname}-fetch-marketplace";
            text = ''
              echo 'fetching marketplace file for' ${lib.escapeShellArg finalPackage.name} >&2

              # this needs to be before TMPDIR is changed, so the output isn't deleted
              # if it uses mktemp
              ${lib.toShellVars { inherit defaultMarketplaceFile; }}
              marketplaceFile=$(realpath "''${1:-$defaultMarketplaceFile}")

              cp ${src}/.agents/plugins/marketplace.json "$marketplaceFile"
            '';
          };
      };
    };

  mkPlugin =
    {
      src,
      meta ? { },
      ...
    }:
    {
      name,
      source,
      description,
    }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit src name;

      meta = meta // {
        description = description;
      };

      installPhase = ''
        mkdir -p $out/share/agents/plugins
        cp -r $src/${lib.escapeShellArg source} $out/share/agents/plugins
      '';

      passthru.pluginDir = "${finalAttrs.finalPackage}/share/agents/plugins";
    });

in

fnOrAttrs:
agentPluginsJoin (
  finalAttrs:
  let
    args = if lib.isFunction fnOrAttrs then fnOrAttrs (args' // finalAttrs) else fnOrAttrs;
    args' = args // {
      inherit plugins;
    };

    marketplaceData = lib.fromJSON (lib.readFile args.marketplace);
    plugins = lib.map (mkPlugin finalAttrs) marketplaceData.plugins;
  in
  addMarketplace {
    marketplaceFile = args.marketplace;
    marketplaceData = marketplaceData;
  } args' finalAttrs
)
