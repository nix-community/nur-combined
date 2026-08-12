# NOTE: This overlay only works with nixpkgs pinned before Aug 25, 2025! After that, ITPP (dependency of dsd-fme) was removed as it was broken - but dsd-fme worked fine somehow
final: prev: {
  dsd-fme = prev.callPackage (
    prev.fetchFromGitHub {
      owner = "lwvmobile";
      repo = "dsd-fme";
      rev = "6ebe3eff584e48739c2d976c4ceb1a89df79afb9";
      sha256 = "sha256-8hKb6t2Zcc3OveXWvx/o1vNMMx5BsPcm9y8XJI7rWCE=";
    }
    + "/package.nix"
  ) { };
}
