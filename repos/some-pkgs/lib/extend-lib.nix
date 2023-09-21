lib:
let
  lib' = lib.recursiveUpdate lib {
    maintainers.SomeoneSerge = {
      email = "sergei.kozlukov@aalto.fi";
      matrix = "@ss:someonex.net";
      github = "SomeoneSerge";
      githubId = 9720532;
      name = "Sergei K";
    };

    types = import ./types.nix { lib = lib'; };

    readByName = import ../read-by-name.nix { lib = lib'; };

    autocallByName = ps: baseDirectory:
      let
        files = lib'.readByName baseDirectory;
        packages = lib.mapAttrs
          (name: file:
            ps.callPackage file { }
          )
          files;
      in
      packages;
  };
in
lib'
