{ stdenv, lib, buildGo111Package, fetchFromGitHub  }:

buildGo111Package rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.3.1";

  goPackagePath = "github.com/tektoncd/cli";
  buildFlagsArray = let t = "${goPackagePath}/pkg/cmd/version"; in ''
     -ldflags=
       -X ${t}.clientVersion=${version} 
  '';
  src = fetchFromGitHub {
    owner = "tektoncd";
    repo = "cli";
    rev = "v${version}";
    sha256 = "1i5hlpgvg5yas09w6kqna8ldrfng0hy79h10dlvc3xrrdb85ds3q";
  };

  meta = with stdenv.lib; {
    homepage    = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
