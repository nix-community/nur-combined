rec {
  /*
    Fetches the upstream NUR repository
    with a given package set.
   */
  fetchNur = nurpkgs: nurpkgs.callPackage (import (builtins.fetchGit {
    url = "https://github.com/nix-community/NUR";
  })) { inherit nurpkgs; };

  /*
    Creates a simple `pkgs' attrset from a certain released channel (to ensure that all deps were
    evaluated and built by Hydra).

    The package set contains several basic configurations parameters and `nur' as overlay.
   */
  nixpkgs = { channel, overlays }: rec {
    packageSet = import (fetchTarball "https://github.com/nixos/nixpkgs-channels/archive/nixos-${channel}.tar.gz");
    nixpkgsArgs = {
      config.allowUnfree = true;
      config.inHydra = true;
      overlays = [
        (self: super: {
          nur = fetchNur self;
        })
      ] ++ overlays;
    };
  };

  /*
    Simple helper to generate a jobset for packages on a given release channel.
   */
  mkJob = { channel, overlays, func, supportedSystems }:
    let set = nixpkgs { inherit channel overlays; }; pkgs = set.packageSet set.nixpkgsArgs;
    in func pkgs (import (builtins.toPath "${pkgs.path}/pkgs/top-level/release-lib.nix") {
      inherit (set) packageSet nixpkgsArgs;
      inherit supportedSystems;
    });
}
