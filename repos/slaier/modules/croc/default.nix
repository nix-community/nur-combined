{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      croc = prev.croc.override {
        buildGoModule = old:
          assert lib.versionOlder old.version "10.0.11";
          final.buildGoModule (old // rec {
            version = "10.0.11";
            src = final.fetchFromGitHub {
              owner = "schollz";
              repo = old.pname;
              rev = "v${version}";
              hash = "sha256-vW67Q/11BPRHkDA1m99+PdxQUoylMt2sx6gZFEzgSNY=";
            };
            vendorHash = "sha256-eejDwlovkGLENvNywtFPmqKcwqr+HB+oURL/sDfhOuA=";
          });
      };
    })
  ];

  services.croc = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    croc
  ];
}
