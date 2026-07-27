{ pkgs, ... }:
{
  nix = {
    channel.enable = false;
    package = pkgs.lixPackageSets.latest.lix; # nixVersions.latest;
    distributedBuilds = true;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "cgroups"
        "pipe-operator"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      extra-deprecated-features = [
        "broken-string-escape"
        "or-as-identifier"
      ];
      use-xdg-base-directories = true;
      auto-allocate-uids = true;
      builders-use-substitutes = true;
      use-cgroups = true;
      substituters = [
        "https://zzzsy.cachix.org"
        "https://attic.xuyh0120.win/lantian"
        "https://cache.garnix.io"
        # "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.numtide.com"
      ];
      trusted-public-keys = [
        "zzzsy.cachix.org-1:rfEIzz0YKP22ZHebgdLVe65S1p3iVB1RUtPMGrIC+DU="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };
  };
}
