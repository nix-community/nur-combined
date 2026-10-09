let
  robotnixSrc = builtins.fetchTarball {
    url = "https://github.com/nix-community/robotnix/archive/b731f1aa2bfd26763714495a12ad50f6a9bd12ca.tar.gz";
    sha256 = "1dv9gxlx05y1xrdlr7axmra08frjz19jmf3spciz470n4g0ljp5v";
  };
  robotnix = import robotnixSrc {
    configuration = { pkgs, ... }: {
      flavor = "lineageos";
      device = "sunfish"; # Pixel 4a is a standard LineageOS target
      stateVersion = "3";

      # For a custom device like waydroid_x86_64, you would typically generate a
      # repo2nix lockfile and set:
      # source.manifest.enable = true;
      # source.manifest.lockfile = ./waydroid-manifest.json;

      # Example: Override 'system/core' to patch ueventd for unprivileged user namespaces
      # source.dirs."system/core".patches = [
      #   ./patches/ueventd-rootless.patch
      # ];

      # Example: Completely replace the 'system/sepolicy' directory with a custom fork
      # source.dirs."system/sepolicy".src = pkgs.fetchFromGitHub {
      #   owner = "my-fork";
      #   repo = "android_system_sepolicy";
      #   rev = "my-branch";
      #   hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      # };
    };
  };
in
# This exposes the raw Android images (system.img, vendor.img, etc.)
robotnix.img
