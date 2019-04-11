{ lib, pkgs, }:

let

  _nixpkgs = lib.pinnedNixpkgs {
    rev = "e20ee8a710f3a8ea378bb664c2dbfa32dcf399a7";
    sha256 = "0h063hhywrb4vj9g1lg9dp0r9h5i8b5n923iminnckkxxbr3iap1";
  };

  mkHelmBinary = { version, flavor, sha256 }: pkgs.stdenv.mkDerivation rec {
    pname = "helm";
    name = "${pname}-${version}";
    inherit version;
    src = builtins.fetchTarball {
    url = "https://storage.googleapis.com/kubernetes-helm/helm-v${version}-${flavor}.tar.gz";
      inherit sha256;
    };
    installPhase = ''
      install -dm755 "$out/bin"
      install -m755 helm "$_"
    '';
  };

  mkKops =  { version, sha256 }: _nixpkgs.kops.overrideAttrs(old: rec {
    pname = "kops";
    name = "${pname}-${version}";
    inherit version;
    src = _nixpkgs.fetchFromGitHub {
      rev = version;
      owner = "kubernetes";
      repo = "kops";
      inherit sha256;
    };
    buildFlagsArray = ''
      -ldflags=
          -X k8s.io/kops.Version=${version}
          -X k8s.io/kops.GitVersion=${version}
    '';
  });

  mkKubernetes = { version, sha256 }: _nixpkgs.kubernetes.overrideAttrs(old: rec {
    pname = "kubernetes";
    name = "${pname}-${version}";
    inherit version;
    src = _nixpkgs.fetchFromGitHub {
      owner = "kubernetes";
      repo = "kubernetes";
      rev = "v${version}";
      inherit sha256;
    };
  });

  buildK8sEnv = { name, config }: pkgs.buildEnv {
    inherit name;
    paths = [
      (mkKubernetes config.k8s)
      (mkKops config.kops)
      (mkHelmBinary config.helm)
    ];
  };
in

rec {
  inherit buildK8sEnv mkHelmBinary mkKubernetes;

  inherit (_nixpkgs) autojump kubetail;
  inherit (_nixpkgs.gitAndTools) git-crypt;

  cedille = _nixpkgs.cedille.override {
    inherit (pkgs.haskellPackages) alex happy Agda ghcWithPackages;
  };

  emacsPackages.cedille = _nixpkgs.emacsPackages.cedille.override {
    inherit cedille;
  };

  erlang = pkgs.beam.interpreters.erlangR20.override {
    enableDebugInfo = true;
    installTargets = "install";
    wxSupport = false;
  };

  gap-pygments-lexer = pkgs.callPackage ./tools/misc/gap-pygments-lexer {
    pythonPackages = pkgs.python2Packages;
  };

  icon-lang = pkgs.callPackage ./development/interpreters/icon-lang {
    withGraphics = false;
  };

  kubectl = (kubernetes.override { components = [ "cmd/kubectl" ]; }).overrideAttrs(oldAttrs: rec {
    pname = "kubectl";
    name = "${pname}-${oldAttrs.version}";
  });

  kubectx = (_nixpkgs.kubectx.override { inherit kubectl; });

  kubernetes = mkKubernetes {
    version = "1.11.7";
    sha256 = "03dq9p6nwkisd80f0r3sp82vqx2ac4ja6b2s55k1l8k89snfxavf";
  };

  kops = mkKops {
    version = "1.11.1";
    sha256 = "0jia8dhawh786grnbpn64hvsdm6wz5p7hqir01q5xxpd1psnzygj";
  };

  # inherit (_nixpkgs) kubernetes-helm;

  # TODO:
  # kubernetes-helm = _nixpkgs.kubernetes-helm.overrideAttrs(oldAttrs: rec {
  #   pname = "helm";
  #   name = "${pname}-${version}";
  #   version = "2.13.1";
  #   goDeps = ./applications/networking/cluster/helm/deps.nix;
  #   src = _nixpkgs.fetchFromGitHub {
  #     owner = pname;
  #     repo = pname;
  #     rev = "v${version}";
  #     sha256 = "05k1w2hqnzijwgz7b7fbq5fki6s2wdcjr5x2rr3jy5gq8iibjsfj
  #   };
  #   buildFlagsArray = ''
  #     -ldflags=-X k8s.io/helm/pkg/version.Version=v${version}
  #     -w
  #     -s
  #   '';
  # });

  kubernetes-helm = mkHelmBinary {
    flavor = "darwin-amd64";
    version = "2.12.3";
    sha256 = "0lcnmwqpf5wwq0iw81nlk5fpj4j5p4r6zkrjvbqw5mrjacpa9qf9";
  };

  kubernetes-helm-2_13_1 = mkHelmBinary {
    flavor = "darwin-amd64";
    version = "2.13.1";
    sha256 = "0a21xigcblhc9wikl7ilqvs7514ds4x71jz4yv2kvv1zjvdd9i8n";
  };

  lab = pkgs.callPackage ./applications/version-management/git-and-tools/lab {};

  noweb = pkgs.callPackage ./development/tools/literate-programming/noweb {
    inherit icon-lang;
    useIcon = false;
  };

} // (if pkgs.stdenv.isDarwin then {

  chunkwm = pkgs.recurseIntoAttrs (pkgs.callPackage ./os-specific/darwin/chunkwm {
    inherit (pkgs) callPackage stdenv fetchFromGitHub imagemagick;
    inherit (pkgs.darwin.apple_sdk.frameworks) Carbon Cocoa ApplicationServices;
  });

  clementine = pkgs.callPackage ./applications/audio/clementine {};

  copyq = pkgs.callPackage ./applications/misc/copyq {};

  diff-pdf = pkgs.callPackage ./tools/text/diff-pdf {
    inherit (pkgs.darwin.apple_sdk.frameworks) Cocoa;
  };

  m-cli = pkgs.m-cli.overrideAttrs (_: rec {
    name = "m-cli-${version}";
    version = "c658afcb";
    src = pkgs.fetchFromGitHub {
      owner = "rgcr";
      repo = "m-cli";
      rev = version;
      sha256 = "1jjf4iqfkbi6jg1imcli3ajxwqpnqh7kiip4h3hc9wfwx639wljx";
    };
  });

  inherit (_nixpkgs) musescore;

  onyx = pkgs.callPackage ./os-specific/darwin/onyx {};

  skhd = pkgs.skhd.overrideAttrs (_: rec {
    name = "skhd-${version}";
    version = "0.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "koekeishiya";
      repo = "skhd";
      rev = "v${version}";
      sha256 = "13pqnassmzppy2ipv995rh8lzw9rraxvi0ph6zgy63cbsdfzbhgl";
    };
  });

  skim = pkgs.callPackage ./applications/misc/skim {};

  sourcetree = pkgs.callPackage ./os-specific/darwin/sourcetree {};

  spotify = pkgs.callPackage ./applications/audio/spotify/darwin.nix {};

} else {

  inherit (_nixpkgs) browserpass;

  tellico = pkgs.libsForQt5.callPackage ./applications/misc/tellico {};

})
