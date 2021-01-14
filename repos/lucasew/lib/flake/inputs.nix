{
  flakeroot ? ../../.
}:
with builtins;
let
  lockfile = (builtins.toString flakeroot) + "/flake.lock";
  json = fromJSON (readFile lockfile);
  nodes = json.nodes;
  inputs = nodes.root.inputs;
  flakeHandler = {
    github = obj: builtins.fetchTarball {
      url = "https://github.com/${obj.owner}/${obj.repo}/archive/${obj.rev}.tar.gz";
      sha256 = obj.narHash;
    };
  };
in builtins.mapAttrs (k: v:
let
  node = nodes.${inputs.${k}};
  type = node.locked.type;
  handler = flakeHandler.${type} node.locked;
in
handler) inputs
# in builtins.mapAttrs (k: v: flakeHandler.${v.locked.type} v.locked) nodes
