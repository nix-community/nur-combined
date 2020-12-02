{ lib, ... }:
let
  # Based on https://gist.github.com/lheckemann/402e61e8e53f136f239ecd8c17ab1deb
  declareEnvironmentRaw =
    { file # Path to the environment definition file
    , withPkgs # Function returning the packages to install
    , name ? lib.removeSuffix ".nix" (baseNameOf file) # Name of the environment
    , drvName ? "${name}-environment" # Name of the generated derivaqtion
    , profile ? "/nix/var/nix/profiles/${name}" # Path to the profile
    , pkgs ? import <nixpkgs> { } # Nixpkgs
    }:
    pkgs.buildEnv {
      name = drvName;
      extraOutputsToInstall = [ "out" "bin" "lib" ];
      paths = (withPkgs pkgs) ++ [
        # Script to rebuild the profile from the same input file.
        (pkgs.writeScriptBin "update-profile" ''
          #!${pkgs.stdenv.shell}
          nix-env -p ${profile} --set -f ${file} --argstr drvName "${name}-environment-$(date -I)"
        '')
        # Manifest to make sure imperative nix-env doesn't work
        # (otherwise it will overwrite the profile, removing all
        # packages other than the newly-installed one).
        (pkgs.writeTextFile {
          name = "break-nix-env-manifest";
          destination = "/manifest.nix";
          text = ''
            throw "Your user environment is a buildEnv which is incompatible with nix-env's built-in env builder. Edit your home expression and run update-profile instead!"
          '';
        })
        # Nixpkgs version, in case the user needs it.
        (pkgs.writeTextFile {
          name = "nixpkgs-version";
          destination = "/nixpkgs-version";
          text = pkgs.lib.version;
        })
      ];
    };
in
rec {
  /* declareEnvironment :: { ... } -> derivation
   *
   * Create a declarative user environment for package management.
   *
   * You probably want to override `baseEnvironment` instead of calling
   * this directly, as the former includes Nix in the environment.
   */
  declareEnvironment = lib.makeOverridable declareEnvironmentRaw;

  /*
   * A minimally working declarative environment, with Nix and the
   * Glibc locales.  Split off declareEnvironment so that Nix can be
   * overriden with `nixUnstable`.
   */
  baseEnvironment = declareEnvironment {
    file = throw "Do not use baseEnvironment directly; override it instead.";
    withPkgs = pkgs: with pkgs; [ nix glibcLocales ];
  };
}
