let lock = with builtins; (fromJSON (readFile ./flake.lock)).nodes.flake-compat.locked; in
(import
  (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${lock.rev}.tar.gz";
    sha256 = lock.narHash;
  })
  { src = ./.; }
).shellNix
