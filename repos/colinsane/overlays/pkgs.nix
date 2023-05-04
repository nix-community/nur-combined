(next: prev:
  # expose all my packages into the root scope:
  # - `additional` packages
  # - `patched` versions of nixpkgs (which necessarily shadow their nixpkgs version)
  # - `pythonPackagesExtensions`
  import ../pkgs
    { pkgs = next; lib = prev.lib; unpatched = prev; }
)
