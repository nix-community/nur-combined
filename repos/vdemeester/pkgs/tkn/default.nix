{ stdenv, lib, buildGoPackage, fetchFromGitHub  }:

buildGoPackage rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.1.2";

  goPackagePath = "github.com/tektoncd/cli";
  buildFlagsArray = let t = "${goPackagePath}/pkg/cmd/version"; in ''
     -ldflags=
       -X ${t}.clientVersion=${version} 
  '';
  src = fetchFromGitHub {
    owner = "tektoncd";
    repo = "cli";
    rev = "v${version}";
    sha256 = "0dj4c703cdl28x9fi42ydbw8ml24bhfrcyafvpdgj7pvajbr3nlh";
  };

  meta = with stdenv.lib; {
    homepage    = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
