{ lib, ... }:
{
  nix.settings = {
    substituters = lib.mkAfter [
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
      "https://cuda-maintainers.cachix.org"
      # "http://nix-cache.whiterun.lucao.net"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
}
