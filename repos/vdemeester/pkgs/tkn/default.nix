{ stdenv, lib, buildGo111Package, fetchFromGitHub  }:

buildGo111Package rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.2.2";

  goPackagePath = "github.com/tektoncd/cli";
  buildFlagsArray = let t = "${goPackagePath}/pkg/cmd/version"; in ''
     -ldflags=
       -X ${t}.clientVersion=${version} 
  '';
  src = fetchFromGitHub {
    owner = "tektoncd";
    repo = "cli";
    rev = "v${version}";
    sha256 = "0qrgd3c5c1wz3mk3x7z0bdsiric2qap47zfa5hgv753fhbvswj5x";
  };

  meta = with stdenv.lib; {
    homepage    = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
