{ pkgs, lib }:

let cargoNix = pkgs.callPackage ./generated/Cargo.nix {};
in
{
  source = pkgs.fetchgit {
    name = "nix-test-runner-source";
    url = "https://github.com/stoeffel/nix-test-runner.git";
    rev = "c45d45b11ecef3eb9d834c3b6304c05c49b06ca2";
    sha256 = "12qqmxi4pmyahhk7537nw75fffbw29g2c7l7g0vzhds0bf9758hl";
  };
  package = cargoNix.workspaceMembers.nix-test-runner.build.overrideAttrs (attrs: rec {
    pname = "nix-test-runner";
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
            github = "stoeffel";
            githubId = 1217681;
            name = "Christoph Hermann";
          }
          # TODO: Change to lib.maintainers.kolloch
          # after https://github.com/NixOS/nixpkgs/pull/86642
          {
            github = "kolloch";
            githubId = 339354;
            name = "Peter Kolloch";
            email = "info@eigenvalue.net";
          }
        ];
        platforms = lib.platforms.all;
      };
  });
}
