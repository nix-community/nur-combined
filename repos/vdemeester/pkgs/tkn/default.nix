{ stdenv, lib, buildGoModule, fetchFromGitHub  }:

buildGoModule rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.7.1";

  goPackagePath = "github.com/tektoncd/cli";
  subPackages = [ "cmd/tkn" ];
  buildFlagsArray = let t = "${goPackagePath}/pkg/cmd/version"; in ''
     -ldflags=
       -X ${t}.clientVersion=${version}
  '';
  src = fetchFromGitHub {
    owner = "tektoncd";
    repo = "cli";
    rev = "v${version}";
    sha256 = "08chgzrhh2c2i37xn67bc77jvwg1rcxa0yrdqdsamph0k9iajh5s";
  };
  modSha256 = "0axczv060rb1n31pizrnydaayxlv9bgcy577dk1f1wv89yshy04x";
  postInstall = ''
    mkdir -p $out/share/bash-completion/completions/
    $out/bin/tkn completion bash > $out/share/bash-completion/completions/tkn
    mkdir -p $out/share/zsh/site-functions
    $out/bin/tkn completion zsh > $out/share/zsh/site-functions/_tkn
  '';
  meta = with stdenv.lib; {
    homepage    = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
