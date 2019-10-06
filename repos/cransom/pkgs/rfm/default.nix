{buildGoModule, fetchFromGitHub, stdenv }:

buildGoModule rec {
    name = "rfm-${version}";
    version = "1.1.0";
    src = fetchFromGitHub {
      owner = "wilriker";
      repo = "rfm";
      rev = "v${version}";
      sha256 = "sha256:0ahsf8vvzs6h2nq59yw9dlqn75wxx8hcp87cqcncz4x867qmf33y";

    };
    modSha256 = "sha256:1qlb5k3jr96vz02qdn5llmwriha4lyzj1vkmaqcdwrp03vx4zjyi";

    #subPackages = [ "." ];
  }
