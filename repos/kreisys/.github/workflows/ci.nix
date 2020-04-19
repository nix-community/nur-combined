with import <nixpkgs/lib>;
let
  # str -> [str]:
  # Returns a list of the attribute paths of all non-broken packages
  # compatible with 'system'.
  getBuildablesFor = system:
    (import ../../ci.nix { inherit system; }).buildables;

  # str -> str -> str:
  # mkJobName "x86_64-darwin" "nested.package" -> "nested_package-x86_64-darwin"
  mkJobName = system: attrPath:
    "${replaceStrings [ "." ] [ "_" ] attrPath}-${system}";

  mkJob = runs-on: attributes: {
    inherit runs-on;
    steps = [
      { uses = "actions/checkout@v2"; }
      { uses = "cachix/install-nix-action@v8"; }
      {
        uses = "cachix/cachix-action@v5";
        "with" = {
          name = "kreisys";
          signingKey = "'\${{ secrets.CACHIX_SIGNING_KEY }}'";
          inherit attributes;
        };
      }
    ];
  };

  mkJobs = system: jobTemplate:
    pipe (getBuildablesFor system) [
      ((flip genAttrs) id)
      (mapAttrs' (n: v: nameValuePair (mkJobName system n) (jobTemplate v)))
    ];

  linuxJobs = mkJobs "x86_64-linux" (mkJob "ubuntu-latest");
  darwinJobs = mkJobs "x86_64-darwin" (mkJob "macos-latest");

in builtins.toJSON {
  name = "CI";
  on.push.branches = [ "master" ];
  jobs = linuxJobs // darwinJobs;
}
