{ pkgs ? import <nixpkgs> { } }:
let
  tmuxHlp = import ./tmuxhelpers.nix { };
  self = {
    realm-cli = pkgs.callPackage ./pkgs/realm-cli {};
    fish-history-merger = pkgs.callPackage ./pkgs/fish-history-merger {};
    wowup = pkgs.callPackage ./pkgs/wowup { };
    strongdm = pkgs.callPackage ./pkgs/sdm { };
    dmenu-afreak = pkgs.callPackage ./pkgs/dmenu { };
    dmenuhist = pkgs.callPackage ./pkgs/dmenuhist { };
    sidequest = pkgs.callPackage ./pkgs/sidequest { };
    awscli = pkgs.callPackage ./pkgs/awscli { };
    dcreemer-1pass = pkgs.callPackage ./pkgs/dcreemer-1pass { };
    tmux-jump = tmuxHlp.mkDerivation rec {
      pluginName = "tmux-jump";
      version = "416f613d3eaadbe1f6f9eda77c49430527ebaffb";
      rtpFilePath = "tmux-jump.tmux";
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postInstall = ''
        ppath=$out/share/tmux-plugins/tmux-jump
        mv $ppath/scripts/tmux-jump.sh $ppath/scripts/tmux-jump-unwrapped.sh
        makeWrapper $ppath/scripts/tmux-jump-unwrapped.sh $ppath/scripts/tmux-jump.sh \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ruby ]}

      '';
      src = pkgs.fetchFromGitHub {
        owner = "schasse";
        repo = pluginName;
        rev = version;
        sha256 = "1xbzdyhsgaq2in0f8f491gwjmx6cxpkf2c35d2dk0kg4jfs505sz";
      };
      dependencies = [ pkgs.ruby ];
    };
    tmux-extrakto = tmuxHlp.mkDerivation rec {
      pluginName = "extrakto";
      version = "0b7d04c3b8118514e853b913bed68e9947d653cd";
      src = pkgs.fetchFromGitHub {
        owner = "laktak";
        repo = "extrakto";
        rev = version;
        sha256 = "11ml0ck5fxnyls83xi7gixgpnpmpp2md2dif6ig8vian9b3v6wjq";
      };
      dependencies = [ pkgs.fzf ];
    };
    tmux-fzf-url = tmuxHlp.mkDerivation rec {
      pluginName = "tmux-fzf-url";
      version = "74d4f13c98cec03e4243adf719275ad880dabde0";
      rtpFilePath = "fzf-url.tmux";
      src = pkgs.fetchFromGitHub {
        owner = "wfxr";
        repo = pluginName;
        rev = version;
        sha256 = "0l43pi31isipd9p1qhj5cmajy70l6ijhzi1jpdmhid7735xnx36q";
      };
      dependencies = [ pkgs.fzf ];
    };
    url-handler-tmux = tmuxHlp.mkDerivation rec {
      pluginName = "url-handler-tmux";
      # version = "lolx";
      # src = ~/coding/url-handler-tmux;
      version = "260432bef882b161a5a5314cdce17147af88c4c0";
      src = pkgs.fetchFromGitHub {
        owner = "afreakk";
        repo = pluginName;
        rev = version;
        sha256 = "1v4igddc3dijnygddsr6zs8664vwhl1v4lpfnb3xxpzlbfyb8j6b";
      };
    };
    fingers = tmuxHlp.mkDerivation rec {
      pluginName = "fingers";
      rtpFilePath = "tmux-fingers.tmux";
      version = "1.0.1";
      src = pkgs.fetchFromGitHub {
        owner = "Morantron";
        repo = "tmux-fingers";
        rev = version;
        sha256 = "0gp37m3d0irrsih96qv2yalvr1wmf1n64589d4qzyzq16lzyjcr0";
        fetchSubmodules = true;
      };
      postInstall = ''
        mkdir -p $out/share/tmux-plugins/fingers/.cache
      '';
      dependencies = [ pkgs.gawk ];
    };
    modules = {
      strongdm = import ./modules/sdm;
      mcfly_with_fix = import ./modules/mcfly;
    };
  };
in
self
