{lib}: let
  githubUrl = repo: tagPrefix: version: file: "https://github.com/${repo}/releases/download/${tagPrefix}${version}/${file}";

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
        (builtins.replaceStrings ["{version}"] [ver.version] ver.asset.file)
      else
        builtins.replaceStrings
        ["{repo}" "{version}"]
        [(ver.source.repo or "") ver.version]
        ver.asset.url;
  in {
    inherit url;
    inherit (ver) hash;
  };

  getPlatform = platform: ver: let
    plat = lib.getAttr platform ver.platforms;
    file = builtins.replaceStrings ["{version}"] [ver.version] plat.file;
  in {
    url =
      githubUrl
      (plat.repo or ver.source.repo)
      (ver.source.tag_prefix or "")
      ver.version
      file;
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
        ver.asset.file
      else
        builtins.replaceStrings
        ["{repo}" "{version}"]
        [ver.source.repo ver.version]
        ver.asset.url;
  in {
    url = applySubstitutions vari.substitutions baseUrl 0;
    inherit (vari) hash;
  };

  getApi = ver: {
    inherit (ver.asset) url hash;
  };

  unpack = ver: ver.asset.unpack or false;

  unpackPlatform = platform: ver:
    (lib.getAttr platform ver.platforms).unpack or ver.asset.unpack or false;
}
