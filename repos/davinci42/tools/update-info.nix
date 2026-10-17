{
  name,
  root ? ../.,
  pkgs ? import <nixpkgs> { },
}:
let
  packages = import root { inherit pkgs; };
  package = pkgs.lib.attrByPath (pkgs.lib.splitString "." name) null packages;
  script = package.updateScript;
  attrPath = script.attrPath or name;
  target = pkgs.lib.attrByPath (pkgs.lib.splitString "." attrPath) null packages;
  snapshot = pkgs.lib.hasInfix "unstable" target.version;
  source = target.src or { };
  sourceUrl = source.url or (builtins.head (source.urls or [ "" ]));
  githubSource = builtins.match "https://(raw.githubusercontent.com|github.com)/([^/]+/[^/]+)/.*" sourceUrl;
  releaseSource = builtins.match "https://github.com/[^/]+/[^/]+/releases/download/([^/]+)/.*" sourceUrl;
  sources = map (
    system:
    let
      platformSource =
        (pkgs.lib.attrByPath (pkgs.lib.splitString "." attrPath) { } (
          import root {
            pkgs = import pkgs.path {
              localSystem = system;
              config = { };
              overlays = [ ];
            };
          }
        )).src or { };
    in
    {
      url = platformSource.url or (builtins.head (platformSource.urls or [ "" ]));
      hash = platformSource.outputHash or "";
    }
  ) (target.meta.platforms or [ ]);
in
{
  command = map toString (pkgs.lib.toList (script.command or script));
  inherit attrPath snapshot sources;
  supportedFeatures = script.supportedFeatures or [ ];
  env = {
    UPDATE_NIX_NAME = target.name;
    UPDATE_NIX_PNAME = target.pname;
    UPDATE_NIX_OLD_VERSION = target.version;
    UPDATE_NIX_ATTR_PATH = attrPath;
  };
  identity = if snapshot && target.src ? rev then target.src.rev else target.version;
  system = pkgs.stdenv.hostPlatform.system;
  upstream =
    if source ? owner && source ? repo then
      "https://github.com/${source.owner}/${source.repo}"
    else if githubSource != null then
      "https://github.com/${builtins.elemAt githubSource 1}"
    else
      null;
  sourceRef =
    source.tag or (source.rev or (if releaseSource != null then builtins.head releaseSource else null));
}
