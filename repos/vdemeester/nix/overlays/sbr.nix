self: super:
let
  compileEmacsFiles = super.callPackage ./emacs/builder.nix;
in
rec {
  scripts = import ../packages/my/scripts {
    inherit (self) stdenv;
  };
  vrsync = import ../packages/my/vrsync {
    inherit (self) stdenv;
  };
  vde-thinkpad = import ../packages/my/vde-thinkpad {
    inherit (self) stdenv;
  };
  bekind = super.callPackage ../../tools/bekind { };
  go-org-readwise = super.callPackage ../../tools/go-org-readwise { };

  my = import ../packages {
    inherit (self) pkgs;
  };

  bookmark-plus = compileEmacsFiles {
    name = "bookmark-plus";
    src = super.fetchFromGitHub {
      owner = "emacsmirror";
      repo = "bookmark-plus";
      rev = "73b8e1c2195860a8c24b5e2961914780c19cf5e3";
      sha256 = "09aprlawi3m7qrdas3zlk52niap2sr741qzfpjwc2c22hrlyv8ng";
    };
  };
  dired-plus = compileEmacsFiles {
    name = "dired-plus";
    src = super.fetchFromGitHub {
      owner = "emacsmirror";
      repo = "dired-plus";
      rev = "db4d82a6b1995a3aa31bd7f2dcaf9b83335d5576";
      sha256 = "10rfjf6gn5cx1kxq97xq7p24rnkw0hnzj32x4hny7bc6s3635d3x";
    };
  };

}
