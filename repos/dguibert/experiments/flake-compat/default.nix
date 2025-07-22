(
  import
  (
    let
      dir = ../..;
      lock = builtins.fromJSON (builtins.readFile (dir + "/flake.lock"));
      nodeName = lock.nodes.root.inputs.flake-compat;
    in
      fetchTarball {
        url = lock.nodes.${nodeName}.locked.url or "https://github.com/edolstra/flake-compat/archive/${lock.nodes.${nodeName}.locked.rev}.tar.gz";
        sha256 = lock.nodes.${nodeName}.locked.narHash;
      }
  )
  {src = dir;}
)
.defaultNix
