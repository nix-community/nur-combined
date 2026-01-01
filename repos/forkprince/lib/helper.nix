# TODO: Merge getSingle & getApi and getPlatform & getApiPlatform
{lib}: let
  githubUrl = repo: tagPrefix: version: file: "https://github.com/${repo}/releases/download/${tagPrefix}${version}/${file}";

  sanitizeName = name:
    builtins.replaceStrings
    [" " "%20"]
    ["-" "-"]
    name;

  sanitizeUrl = url:
    builtins.replaceStrings
    [" "]
    ["%20"]
    url;

  extractName = url:
    sanitizeName (baseNameOf (builtins.elemAt (lib.splitString "?" url) 0));

  substitute = {
    version,
    repo ? "",
    template,
  }:
    builtins.replaceStrings
    ["{version}" "{repo}"]
    [version repo]
    template;

  applySubstitutions = subs: let
    applySubs = t: idx:
      if idx >= builtins.length subs
      then t
      else
        applySubs
        (builtins.replaceStrings ["{${toString idx}}"] [(builtins.elemAt subs idx)] t)
        (idx + 1);
  in
    applySubs;
in {
  read = path: builtins.fromJSON (builtins.readFile path);

  getSingle = ver: let
    hasFile = ver.asset ? file;
    isGithub = (ver.source.type or "") == "github-release" && hasFile;

    url =
      if isGithub
      then
        githubUrl
        ver.source.repo
        (ver.source.tag_prefix or "")
        ver.version
        (substitute {
          version = ver.version;
          template = ver.asset.file;
        })
      else
        substitute {
          version = ver.version;
          repo = ver.source.repo or "";
          template = ver.asset.url;
        };

    name = extractName url;
  in {
    inherit url name;
    inherit (ver) hash;
  };

  getPlatform = platform: ver: let
    plat = lib.getAttr platform ver.platforms;
    hasCustomUrl = plat ? url;
    platformVersion = plat.version or ver.version;
  in
    if hasCustomUrl
    then let
      rawUrl = substitute {
        version = platformVersion;
        repo = plat.repo or ver.source.repo or "";
        template = plat.url;
      };
      url = sanitizeUrl rawUrl;
      name = extractName url;
    in {
      inherit url name;
      inherit (plat) hash;
    }
    else let
      file = substitute {
        version = platformVersion;
        template = plat.file;
      };
    in {
      url =
        githubUrl
        (plat.repo or ver.source.repo)
        (plat.tag_prefix or ver.source.tag_prefix or "")
        platformVersion
        file;
      name = sanitizeName file;
      inherit (plat) hash;
    };

  getVariant = variant: ver: let
    vari = lib.getAttr variant ver.variants;
    hasFile = ver.asset ? file;
    isGithub = (ver.source.type or "") == "github-release" && hasFile;

    baseUrl =
      if isGithub
      then
        githubUrl
        ver.source.repo
        (ver.source.tag_prefix or "")
        ver.version
        (substitute {
          version = ver.version;
          template = ver.asset.file;
        })
      else
        substitute {
          version = ver.version;
          repo = ver.source.repo;
          template = ver.asset.url;
        };

    url = applySubstitutions vari.substitutions baseUrl 0;
    name = extractName url;
  in {
    inherit url name;
    inherit (vari) hash;
  };

  getApi = ver: let
    url = sanitizeUrl ver.asset.url;
    name = extractName url;
  in {
    inherit url name;
    inherit (ver.asset) hash;
  };

  getApiPlatform = platform: ver: let
    plat = lib.getAttr platform ver.platforms;
    url = sanitizeUrl plat.url;
    name = extractName url;
  in {
    inherit url name;
    inherit (plat) hash;
  };

  unpack = ver: ver.asset.unpack or false;

  unpackPlatform = platform: ver:
    (lib.getAttr platform ver.platforms).unpack or ver.asset.unpack or false;

  getVersion = platform: ver:
    if ver ? platforms
    then let
      plat = lib.getAttr platform ver.platforms;
    in
      plat.version or ver.version
    else ver.version;
}
