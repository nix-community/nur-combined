{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.8.0";

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
    sha256 = "00qznm02gsxvgxjakj7qpm8rgx82bnyycw4l7kpnrly5m07nm9gv";
  };
  modSha256 = "0a9m46aspqbvnnvhg6qv0adarr7plj91vknbz9idc8yz4sv9wi8j";

  postInstall = ''
    # manpages
    manRoot="$out/share/man"
    mkdir -p "$manRoot/man1"
    for manFile in docs/man/man1/*; do
      manName="$(basename "$manFile")" # "docker-build.1"
      gzip -c "$manFile" > "$manRoot/man1/$manName.gz"
    done
    # completions
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
