{lib}: {
  read = path: builtins.fromJSON (builtins.readFile path);

  getSingle = ver: {
    url = let
      tmpl = ver.asset.url or ver.asset.url_template;
    in
      builtins.replaceStrings
      ["{repo}" "{version}"]
      [(ver.source.repo or "") ver.version]
      tmpl;
    inherit (ver) hash;
  };

  getPlatform = platform: ver: let
    plat = lib.getAttr platform ver.platforms;
    repo = plat.repo or ver.source.repo;
    file = builtins.replaceStrings ["{version}"] [ver.version] plat.file;
  in {
    url = "https://github.com/${repo}/releases/download/${ver.version}/${file}";
    inherit (plat) hash;
  };

  getVariant = variant: ver: let
    vari = lib.getAttr variant ver.variants;
    tmpl = ver.asset.url or ver.asset.url_template;

    withStd =
      builtins.replaceStrings
      ["{repo}" "{version}"]
      [ver.source.repo ver.version]
      tmpl;

    applySubs = t: idx:
      if idx >= builtins.length vari.substitutions
      then t
      else
        applySubs
        (builtins.replaceStrings
          ["{${toString idx}}"]
          [(builtins.elemAt vari.substitutions idx)]
          t)
        (idx + 1);
  in {
    url = applySubs withStd 0;
    inherit (vari) hash;
  };

  getApi = ver: {
    inherit (ver.asset) url hash;
  };

  unpack = ver: ver.asset.unpack or false;

  unpackPlatform = platform: ver: let
    plat = lib.getAttr platform ver.platforms;
  in
    plat.unpack or (ver.asset.unpack or false);
}
