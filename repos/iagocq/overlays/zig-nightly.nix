final: prev:
let
  pkgs = prev;
in
{
  zig = (pkgs.zig.override { llvmPackages = pkgs.llvmPackages_13; }).overrideAttrs (old: rec {
    version = "0.10.0-dev";
    src = pkgs.fetchFromGitHub {
      owner = "ziglang";
      repo = "zig";
      rev = "a5c7742ba6fc793608b8bb7ba058e33eccd9cfec";
      hash = "sha256-nObE1WX5nY40v6ryaAB75kVKeE+Q76yKgfR/DYRDcwA=";
    };
  });

  zls = pkgs.zls.overrideAttrs (old: rec {
    version = "0.2.0";
    src = pkgs.fetchFromGitHub {
      fetchSubmodules = true;
      owner = "zigtools";
      repo = "zls";
      rev = "189de1768dfc95086a15664123c11144e9ac1402";
      sha256 = "sha256-iTYwK76N0efm/e0JZbxKKZ/j+dej9BX/SNWeox+iLjA=";
    };
  });
}
