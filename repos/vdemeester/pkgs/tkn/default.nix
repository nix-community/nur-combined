{ stdenv, lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.9.0";

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
    sha256 = "11wcips37k1vfif2ckpdxgf1p5yh2zgccv3ngnl1jjm8kcqla40q";
  };
  modSha256 = "160174vw34v9w53azkzslcskzhsk1dflccfbvl1l38xm624fj4lw";

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
    homepage = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
