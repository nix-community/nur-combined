{ lib
, base16, base16-templates-source, base16-schemes
, symlinkJoin
}: with lib; let
  inherit (base16-templates-source) sources;
  mapRepo = slug: repo: let
    addPassthru = drv: {
      import = import "${drv.nix}";
      templated = mapAttrs (key: conf: rec {
        path = "${drv}/${conf.output}/base16-${drv.scheme-slug}${conf.extension}";
        content = builtins.readFile path;
      }) repo.config;
    };
    build = templateData: base16.buildTemplate {
      pname = "base16-template-${slug}-${templateData.scheme-slug}";
      inherit slug templateData;
      inherit (repo) version;
      src = base16.repoSrc repo;

      passthru = {
        inherit repo;
        inherit (templateData) scheme-slug;
      };
    };
    withTemplateData = templateData: drvPassthru addPassthru (build templateData);
    schemes = mapAttrs (schemeSlug: scheme:
      withTemplateData (lib.base16.evalScheme scheme.data).templateData
    ) base16-schemes.all;
    combined = symlinkJoin {
      name = "base16-${slug}";
      paths = attrValues schemes;
    };
  in combined // {
    inherit withTemplateData schemes;
  };
in dontRecurseIntoAttrs (mapAttrs mapRepo sources) // {
  inherit sources;
  names = attrNames sources;
}
