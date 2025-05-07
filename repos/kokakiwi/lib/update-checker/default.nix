{ lib

, formats
, writeShellScript

, nvchecker
}:
{
  name ? "update-checker",

  packages,

  nvcheckerConfig ? { },

  configs ? { },
  sources ? { },
  overrides ? { },

  includePrereleases ? false,
  doWarn ? true
}: let
  json = formats.json { };
  toml = formats.toml { };

  normalizedPackages = let
    checks = [
      {
        check = name: drv: drv ? src && drv.src ? url;
        message = "No URL provided";
      }
      {
        check = name: drv: if lib.hasInfix "unstable" drv.name
          then drv ? src && drv.src ? rev
          else drv ? version;
        message = "No revision or version";
      }
    ];
  in lib.filterAttrs (name: drv: let
    failed = map (x: x.message) (lib.filter (x: !(x.check name drv)) checks);
    failedStr = lib.concatMapStringsSep "\n" (msg: "- ${msg}") failed;
  in if failed == [ ] || lib.hasAttr name sources then true
  else lib.trace "warning: ${name}\n${failedStr}" false) packages;

  oldVerFile = let
    data = {
      version = 2;
      data = lib.mapAttrs (name: drv: let
        inherit (drv) src;

        isUnstable = lib.hasInfix "unstable" drv.name;
      in {
        version = if isUnstable then src.rev else drv.version;
      }) normalizedPackages;
    };
  in json.generate "oldver.json" data;

  mkEntry = name: drv: let
    inherit (drv) src;

    isUnstable = lib.hasInfix "unstable" drv.name;

    github = builtins.match "https://github.com/([^/]+)/([^/]+)(/.*)?" src.url;
    codeberg = builtins.match "https://codeberg.org/([^/]+)/([^/]+)(/.*)?" src.url;
    pypi = builtins.match "mirror://pypi/./([^/]+)/.*" src.url;
    cratesio = builtins.match "https://crates.io/api/v1/crates/([^/]+)/.*" src.url;

    unknownUrl = lib.warnIf doWarn "${name}: Unrecognized URL: ${src.url}" null;

    baseConfig = let
      githubOwner = builtins.elemAt github 0;
      githubRepo = lib.removeSuffix ".git" (builtins.elemAt github 1);

      codebergOwner = builtins.elemAt codeberg 0;
      codebergRepo = lib.removeSuffix ".git" (builtins.elemAt codeberg 1);

      pypiName = builtins.elemAt pypi 0;

      cratesioName = builtins.elemAt cratesio 0;

      stableConfig = if github != null then {
        source = "github";
        github = "${githubOwner}/${githubRepo}";
        use_max_tag = true;
      }
      else if codeberg != null then {
        source = "gitea";
        host = "codeberg.org";
        gitea = "${codebergOwner}/${codebergRepo}";
        use_max_tag = true;
      }
      else if pypi != null then {
        source = "pypi";
        pypi = pypiName;
      }
      else if cratesio != null then {
        source = "cratesio";
        cratesio = cratesioName;
      }
      else null;

      unstableConfig = if github != null then {
        source = "git";
        git = "https://github.com/${githubOwner}/${githubRepo}.git";
        use_commit = true;
      }
      else null;
    in if sources ? ${name} then sources.${name}
    else if isUnstable then unstableConfig
    else stableConfig;

    tagName = if src ? rev && src.rev != null then (lib.removePrefix "refs/tags/" src.rev)
    else if src ? tag then src.tag
    else null;

    config = if baseConfig != null then
      baseConfig
      // configs.${name} or { }
      // lib.optionalAttrs (tagName != null && lib.hasPrefix "v" tagName) {
        prefix = "v";
      }
      // lib.optionalAttrs (!includePrereleases) {
        exclude_regex = ".*-(alpha|beta|rc).*";
      }
      // overrides.${name} or { }
    else unknownUrl;
  in if config != null then lib.nameValuePair name config else null;
  entries = lib.pipe normalizedPackages [
    (lib.mapAttrsToList mkEntry)
    (lib.filter (e: e != null))
    builtins.listToAttrs
  ];

  config = {
    __config__ = nvcheckerConfig // {
      oldver = toString oldVerFile;
      newver = "/tmp/newver.json";
    };
  } // entries;
  configFile = toml.generate "nvchecker.toml" config;
in writeShellScript name ''
  echo "Config file: ${configFile}"
  ${nvchecker}/bin/nvchecker --file ${configFile} "$@"
''
