{ config, pkgs, ... }:

{
  nix.package = let
    # Use latest via fetchGit, if available
    nix_src =
        if (builtins ? fetchGit) then
          builtins.fetchGit { url = https://github.com/dtzWill/nix; ref = "experimental/mux"; }
        else
        # Manually updated sometimes
        let
          # /nix/store/7adx0k67va5cwsczmisaran78px1d47r-nix-2.0dtz5903_f849d64/bin/nix
          rev = "f849d64";
          src = pkgs.fetchFromGitHub {
            owner = "dtzWill";
            repo = "nix";
            inherit rev;
            sha256 = "13mj8gpwklwfpgr6vi6zblaxnwx3i8lsxap1f8n05y49b4wp56h5";
          };
        in src // { revCount = 5903; shortRev = builtins.substring 0 7 rev; };
    nix_release = import (nix_src + "/release.nix") {
      nix = nix_src;
      #nixpkgs = <nixpkgs>;
      # Use branch with version of musl kludged into accommodating Nix badness re:fork+threads
      nixpkgs = fetchGit { url = https://github.com/dtzWill/nixpkgs; ref = "experimental/musl-fork-malloc-kludge"; };
      #nixpkgs = fetchGit { url = https://github.com/dtzWill/nixpkgs; ref = "update/musl-1.1.20-staging"; };
      #nixpkgs = fetchGit { url = https://github.com/dtzWill/nixpkgs; ref = "experimental/musl-new-gc"; };
    };
  in
    nix_release.build.x86_64-linux; # // { perl-bindings = nix_release.perlBindings.x86_64-linux; };
}
