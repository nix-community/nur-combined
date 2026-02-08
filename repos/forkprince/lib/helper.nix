{lib}: rec {
  githubUrl = repo: tagPrefix: version: file: "https://github.com/${repo}/releases/download/${tagPrefix}${version}/${file}";

  forgejoUrl = instance: repo: tagPrefix: version: file: "${instance}/${repo}/releases/download/${tagPrefix}${version}/${file}";

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

  read = path: builtins.fromJSON (builtins.readFile path);

  getSingle = ver: let
    sourceType = ver.source.type or "";
    tagPrefix = ver.source.tag_prefix or "";
  in
    # GitHub repository
    if sourceType == "github-repo"
    then let
      parts = lib.splitString "/" ver.source.repo;
    in {
      owner = builtins.elemAt parts 0;
      repo = builtins.elemAt parts 1;
      tag = "${tagPrefix}${ver.version}";
      inherit (ver) hash;
    }
    else let
      url =
        # GitHub release
        if sourceType == "github-release" && ver.asset ? file
        then
          githubUrl
          ver.source.repo
          tagPrefix
          ver.version
          (substitute {
            inherit (ver) version;
            template = ver.asset.file;
          })
        # Forgejo release
        else if sourceType == "forgejo-release" && ver.asset ? file
        then
          forgejoUrl
          ver.source.instance
          ver.source.repo
          tagPrefix
          ver.version
          (substitute {
            inherit (ver) version;
            template = ver.asset.file;
          })
        # Custom URL
        else
          sanitizeUrl (substitute {
            inherit (ver) version;
            repo = ver.source.repo or "";
            template = ver.asset.url;
          });
    in {
      inherit url;
      name = extractName url;
      hash = ver.asset.hash or ver.hash;
    };

  getPlatform = platform: ver: let
    settings = lib.getAttr platform ver.platforms;
    version = settings.version or ver.version;
    sourceType = ver.source.type or "";

    url =
      # Custom URL
      if settings ? url
      then
        sanitizeUrl (substitute {
          inherit version;
          repo = settings.repo or ver.source.repo or "";
          template = settings.url;
        })
      # Forgejo release
      else if sourceType == "forgejo-release"
      then
        forgejoUrl
        (settings.instance or ver.source.instance)
        (settings.repo or ver.source.repo)
        (settings.tag_prefix or ver.source.tag_prefix or "")
        version
        (substitute {
          inherit version;
          template = settings.file;
        })
      # GitHub release
      else
        githubUrl
        (settings.repo or ver.source.repo)
        (settings.tag_prefix or ver.source.tag_prefix or "")
        version
        (substitute {
          inherit version;
          template = settings.file;
        });
  in {
    inherit url;
    name = extractName url;
    inherit (settings) hash;
  };

  getVariant = variant: ver: let
    settings = lib.getAttr variant ver.variants;
    sourceType = ver.source.type or "";
    tagPrefix = ver.source.tag_prefix or "";

    baseUrl =
      # GitHub release
      if sourceType == "github-release" && ver.asset ? file
      then
        githubUrl
        ver.source.repo
        tagPrefix
        ver.version
        (substitute {
          inherit (ver) version;
          template = ver.asset.file;
        })
      # Forgejo release
      else if sourceType == "forgejo-release" && ver.asset ? file
      then
        forgejoUrl
        ver.source.instance
        ver.source.repo
        tagPrefix
        ver.version
        (substitute {
          inherit (ver) version;
          template = ver.asset.file;
        })
      # Custom URL
      else
        substitute {
          inherit (ver) version;
          inherit (ver.source) repo;
          template = ver.asset.url;
        };

    url = applySubstitutions settings.substitutions baseUrl 0;
  in {
    inherit url;
    name = extractName url;
    inherit (settings) hash;
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
