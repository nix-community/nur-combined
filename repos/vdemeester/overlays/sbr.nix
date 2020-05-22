self: super:
let
  compileEmacsFiles = super.callPackage ./emacs/builder.nix;
in
rec {
  scripts = import ../pkgs/scripts {
    inherit (self) stdenv;
  };
  tmux-tpm = import ../pkgs/tmux-tpm {
    inherit (self) stdenv lib fetchFromGitHub;
  };
  vscodeliveshare = import ../pkgs/vscodeliveshare {
    inherit (self) stdenv vscode-utils autoPatchelfHook xorg gnome3 utillinux openssl icu zlib curl lttng-ust libsecret libkrb5 gcc libunwind binutils;
  };
  vrsync = import ../pkgs/vrsync {
    inherit (self) stdenv lib;
  };
  vde-thinkpad = import ../pkgs/vde-thinkpad {
    inherit (self) stdenv lib;
  };

  my = import ../pkgs { };

  emacs27 = (self.emacs.override { srcRepo = true; }).overrideAttrs (
    old: {
      name = "emacs-dev";
      version = "27.0.91";
      src = super.fetchFromGitHub {
        owner = "emacs-mirror";
        repo = "emacs";
        rev = "emacs-27.0.91";
        sha256 = "0mlrg2npy1r79laahkgzhxd1qassfcdz8qk1cpw7mqgf6y5x505h";
      };
      buildInputs = old.buildInputs ++ [ super.jansson ];
      patches = [
        ./patches/clean-env.patch
      ];
    }
  );

  bookmark-plus = compileEmacsFiles {
    name = "bookmark-plus";
    src = super.fetchFromGitHub {
      owner = "emacsmirror";
      repo = "bookmark-plus";
      rev = "b6a71e8d153ae8b7bc9afed1cf7659765cfc1b0e";
      sha256 = "1nj9dci6wgwc531vigirx70g3nsw33bsh6ni3bq4dl0x1s4zy6gz";
    };
  };
  dired-plus = compileEmacsFiles {
    name = "dired-plus";
    src = super.fetchFromGitHub {
      owner = "emacsmirror";
      repo = "dired-plus";
      rev = "b51974b84b861592c3519117f3f51ee557ca01ba";
      sha256 = "0s59yd0axnja1zxc8snx013flf0f76n546i5ix5p0ngcbbhmm5kb";
    };
  };

}
