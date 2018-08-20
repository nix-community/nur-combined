{ stdenv, lib, buildGoPackage, fetchFromGitHub, go-bindata }:

buildGoPackage rec {
  name = "kops-${version}";
  inherit (meta) version;

  goPackagePath = "k8s.io/kops";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "kops";
    rev = version;
    sha256 = "1ga83sbhvhcazran6xfwgv95sg8ygg2w59vql0yjicj8r2q01vqp";
  };

  buildInputs = [ go-bindata ];
  subPackages = [ "cmd/kops" ];

  buildFlagsArray = ''
    -ldflags=
        -X k8s.io/kops.Version=${version}
        -X k8s.io/kops.GitVersion=${version}
  '';

  preBuild = ''
    (cd go/src/k8s.io/kops
     go-bindata -o upup/models/bindata.go -pkg models -prefix upup/models/ upup/models/...)
  '';

  postInstall = ''
    mkdir -p $bin/share/bash-completion/completions
    mkdir -p $bin/share/zsh/site-functions
    $bin/bin/kops completion bash > $bin/share/bash-completion/completions/kops
    $bin/bin/kops completion zsh > $bin/share/zsh/site-functions/_kops
  '';

  meta = with stdenv.lib; {
    version = "1.10.0";
    description = "Easiest way to get a production Kubernetes up and running";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ offline yurrriq zimbatm ];
    platforms = platforms.unix;
  };
}
