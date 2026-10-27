{
  inputs,
  config,
  lib,
  options,
  pkgs,
  ...
}:
{
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [
      "cgroups"
      "nix-command"
      "flakes"
    ];
    flake-registry = "/etc/nix/registry.json";
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://slaier.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "slaier.cachix.org-1:NyXPOqlxuGWgyn0ApNHMopkbix3QjMUAcR+JOjjxLtU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    use-cgroups = true;
    extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
  };

  nix.gc = {
    automatic = true;
    dates = "Wed *-*-* 12:00:00";
    options = "--delete-older-than 5d";
    persistent = false;
  };

  nix.extraOptions = lib.mkIf (options ? sops) ''
    !include ${config.sops.secrets.nix_access_token.path}
  '';

  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
  ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.ccache = {
    enable = true;
    cacheDir = "/nix/var/cache/ccache";
    packageNames = [ "audio-cpp-vulkan" ];
  };
  security.wrappers.nix-ccache.source = lib.mkForce (
    lib.getExe (
      (pkgs.writeCBin "nix-ccache" ''
        #include <err.h>
        #include <regex.h>
        #include <unistd.h>

        #define CCACHE "${lib.getExe pkgs.ccache}"

        int main(int argc, char *argv[]) {
          regex_t allowed;
          if (regcomp(&allowed, "^(-[CVsz]|--(clear|version|show-stats|zero-stats))$", REG_EXTENDED | REG_NOSUB))
            err(1, "regcomp");

          // if any arg isn't on the allowlist, run `ccache` w/o args
          for (int i = 1; i < argc; i++)
            if (regexec(&allowed, argv[i], 0, nullptr, 0))
              argv[1] = nullptr;

          argv[0] = CCACHE;
          execve(CCACHE, argv, (char *[]){ "CCACHE_DIR=${config.programs.ccache.cacheDir}", nullptr });
          err(127, CCACHE);
        }
      '').overrideAttrs
        { env.NIX_CFLAGS_COMPILE = "-std=c23"; }
    )
  );

  system.stateVersion = "26.05";
}
