oldLib:
let
  diff =
    {
      maintainers.SomeoneSerge = {
        email = "sergei.kozlukov@aalto.fi";
        matrix = "@ss:someonex.net";
        github = "SomeoneSerge";
        githubId = 9720532;
        name = "Sergei K";
      };

      readByName = import ../read-by-name.nix { lib = oldLib; };

      autocallByName = ps: baseDirectory:
        let
          files = lib.readByName baseDirectory;
          packages = oldLib.mapAttrs
            (name: file:
              ps.callPackage file { }
            )
            files;
        in
        packages;
    };
  lib = oldLib.recursiveUpdate oldLib diff;
in
{
  inherit diff lib;
}
