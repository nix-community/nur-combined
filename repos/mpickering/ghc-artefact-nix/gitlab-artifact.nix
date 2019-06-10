{ stdenv }:
{ branch, fork }:

let
  mkUrl = config: "https://gitlab.haskell.org/${fork}/ghc/-/jobs/artifacts/${branch}/raw/${config.tarball}?job=${config.job}";

  # job: the GitLab CI job we should pull the bindist from
  # ncursesVersion: the ncurses version which the bindist expects
  configs = {
    "i386-linux"   = {
      job = "validate-i386-linux-fedora27";
      tarball = "ghc-x86_64-fedora27-linux.tar.gz";
      ncursesVersion = "6";
    };
    "x86_64-linux" = {
      job = "validate-x86_64-linux-fedora27";
      tarball = "ghc-x86_64-fedora27-linux.tar.xz";
      ncursesVersion = "6";
    };
    "aarch64-linux" = {
      job = "validate-aarch64-linux-deb9";
      ncursesVersion = "5";
    };
    "x86_64-darwin" = {
      job = "validate-x86_64-darwin";
      tarball = "ghc-x86_64-apple-darwin.tar.xz";
      ncursesVersion = "6";
    };
  };

  config = configs.${stdenv.hostPlatform.system}
    or (throw "cannot bootstrap GHC on this platform");

in {
  bindistTarball = builtins.fetchurl (mkUrl config);
  inherit (config) ncursesVersion;
}

