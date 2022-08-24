final: prev:
let
  pkgs = prev;
in
{
  zig = (pkgs.zig.override { llvmPackages = pkgs.llvmPackages_14; }).overrideAttrs (old: rec {
    version = "0.10.0-dev";
    src = pkgs.fetchFromGitHub {
      owner = "ziglang";
      repo = "zig";
      rev = "c84e5ee87852eafff0cbf986bf02c5221cbcec35";
      hash = "sha256-GicNLPwUIXfKLs8M6ZQ8UX7PGOTy5r31FBQMWUGoEUE=";
    };
    patches = [];
  });

  zls = pkgs.zls.overrideAttrs (old: rec {
    version = "0.2.0";
    src = pkgs.fetchFromGitHub {
      fetchSubmodules = true;
      owner = "zigtools";
      repo = "zls";
      rev = "a18ec394f16a17cc1db20dedaabc42ce9b7f9a9d";
      sha256 = "sha256-lSGsUSHS1gQXzn0rKoKFKkQFOs9Ig7MUpL54PaLxLq8=";
    };
  });
}
