rec {

  fetchTarballFromGitHub =
    { owner, repo, rev, sha256, ... }:
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/tarball/${rev}";
      inherit sha256;
  };

  fromJSONFile = f: builtins.fromJSON (builtins.readFile f);

  seemsDarwin = null != builtins.match ".*darwin$" builtins.currentSystem;

  fetchNixpkgs = args@{ rev, sha256, ... }:
    fetchTarballFromGitHub (args // { owner = "NixOS"; repo = "nixpkgs"; });

  pinnedNixpkgs = args: import (fetchNixpkgs args) {};

  mkEksctl = { pkgs, version, sha256 }: pkgs.eksctl.overrideAttrs(_: {
    inherit version;
    src = pkgs.fetchFromGitHub {
      owner = "weaveworks";
      repo = "eksctl";
      rev = version;
      inherit sha256;
    };
  });

  mkHelmBinary = { pkgs, version, flavor, sha256 }: pkgs.stdenv.mkDerivation rec {
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

  mkHelmfile = { pkgs, version, sha256, modSha256 }: pkgs.helmfile.overrideAttrs(_: {
    name = "helmfile-${version}";
    pname = "helmfile";
    inherit modSha256 version;
    src = pkgs.fetchFromGitHub {
      owner = "roboll";
      repo = "helmfile";
      rev = "v${version}";
      inherit sha256;
    };
    buildFlagsArray = ''
      -ldflags=
          -X main.Version=${version}
    '';
  });

  mkKops = { pkgs, version, sha256 }@args: pkgs.mkKops (builtins.removeAttrs args ["pkgs"]);

  mkKubernetes = { pkgs, version, sha256 }@args: pkgs.mkKubernetes (builtins.removeAttrs args ["pkgs"]);

  buildK8sEnv = { pkgs, name, config }:
    let
      deps = rec {
        eksctl = mkEksctl({ inherit pkgs; } // config.eksctl);
        kubernetes-helm = mkHelmBinary ({ inherit pkgs; } // config.helm);
        kubernetes = mkKubernetes ({ inherit pkgs; } // config.k8s);
        kubectl = (kubernetes.override { components = [ "cmd/kubectl" ]; }).overrideAttrs(_: { pname = "kubectl"; });
        kubectx = pkgs.kubectx.override { inherit kubectl; };
        kubefwd = pkgs.kubefwd.override { inherit kubectl; };
        helmfile = (mkHelmfile ({ inherit pkgs; } // config.helmfile)).override { inherit kubernetes-helm; };
        kops = mkKops ({ inherit pkgs; } // config.kops);
        inherit (pkgs) kubetail;
      };
    in
    pkgs.buildEnv {
      inherit name;
      paths = with deps; [
        eksctl
        helmfile
        kops
        kubectx
        kubefwd
        kubernetes
        kubernetes-helm
        kubetail
      ];
      passthru = { inherit config pkgs; } // deps;
    };

}
