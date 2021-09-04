{ lib
, base16, base16-schemes-source
, symlinkJoin
}: with lib; let
  inherit (base16-schemes-source) sources;
  mapRepo = slug: repo: let
    schemeNames = repo.schemes or (singleton slug);
    addPassthru = drv: {
      import = import "${drv.nix}";
      schemes = genAttrs schemeNames (key: rec {
        path = "${drv}/${key}.yaml";
        data = importJSON path;
      });
    };
    drv = base16.buildScheme {
      inherit slug;
      inherit (repo) version;
      src = base16.repoSrc repo;

      passthru = {
        inherit schemeNames repo;
      };
    };
  in lib.drvPassthru addPassthru drv;
  schemes = mapAttrs mapRepo sources;
  all = symlinkJoin {
    name = "base16-schemes";
    paths = attrValues schemes;
  };
in all // dontRecurseIntoAttrs schemes // {
  inherit sources;
  names = attrNames sources;
  all = let
    mapScheme = schemeRepo: schemeName: nameValuePair schemeName schemeRepo.schemes.${schemeName};
    mapSchemeRepo = schemeRepo: map (mapScheme schemeRepo) schemeRepo.schemeNames;
  in listToAttrs (concatMap mapSchemeRepo (attrValues schemes));
}
