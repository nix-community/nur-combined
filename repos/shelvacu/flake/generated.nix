{
  lib,
  allInputs,
  vacuRoot,
  ...
}:
{
  vacuBuilds.generated.putInPackages = true;
  perSystem =
    {
      system,
      pkgs,
      config,
      ...
    }:
    let
      pyPkgs = pkgs.python313Packages;
      py = pyPkgs.python;
      makePathFor =
        pyPkg:
        let
          python = pyPkg.pythonModule or py;
        in
        pkgs.runCommand "python-path-for-${pyPkg.name}"
          { propagatedBuildInputs = pyPkg.propagatedBuildInputs; }
          ''
            main="$out/${python.sitePackages}"
            mkdir -p "$main"
            cd "$main"
            for p in "''${pkgsHostTarget[@]}"; do
              for thing in "$p"/${python.sitePackages}/*; do
                if [[ $thing == */__pycache__ ]]; then
                  continue
                fi
                ln -s "$thing"
              done
            done
          '';
    in
    {
      vacuBuildDerivations.generated = pkgs.linkFarm "generated" {
        "liam-test/hints.py" = pkgs.writeText "hints.py" (
          import /${vacuRoot}/typesForTest.nix {
            name = "liam";
            inherit lib;
            inherit (allInputs) self nixpkgs;
          }
        );
        # "archive/python-env" = builtins.dirOf (builtins.dirOf archive.interpreter);
        "dns-update/python-env" = makePathFor config.packages.dns-update;
        "dnspython" = pyPkgs.dnspython;
        "mailtest/python-env" =
          if system == "x86_64-linux" then
            makePathFor allInputs.self.checks.x86_64-linux.liam.nodes.checker.vacu.mailtest.smtp
          else
            py.withPackages (
              p: with p; [
                imap-tools
                requests
              ]
            );
        "general-env" = py.withPackages (p: with p; [ scriptipy ]);
      };
    };
}
