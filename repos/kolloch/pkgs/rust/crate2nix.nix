{ pkgs, lib }:

let cargoNix = pkgs.callPackage ./generated/Cargo.nix {};
in
{
  source =
    let
      # Trying to work around weird restrictions in nur packages.
      repo = pkgs.fetchgit {
        name = "crate2nix-source";
        url = "https://github.com/kolloch/crate2nix.git";
        rev = "daabda2a2044b7445f1f2e2111b58ec139d4d4b4";
        sha256 = "1wxrlsnghf7yykdpx8p3sxcka65j68szkjcdhfy4a7aasnwsv8bf";
      };
    in "${repo}/crate2nix";

  package = cargoNix.workspaceMembers.crate2nix.build.overrideAttrs (attrs: rec {
    pname = "crate2nix";
    name = "${pname}-${version}";
    # Not necessary anymore on unstable.
    version = attrs.crateVersion;
    meta = {
      description = "Nix build file generator for rust crates.";
      longDescription = ''
        Crate2nix generates nix files from Cargo.toml/lock files
        so that you can build every crate individually in a nix sandbox.
      '';
      homepage = https://github.com/kolloch/crate2nix;
      license = lib.licenses.asl20;
      maintainers = [
        {
          github = "kolloch";
          githubId = 339354;
          name = "Peter Kolloch";
        }
        lib.maintainers.andir
      ];
      platforms = lib.platforms.all;
    };
  });
}
