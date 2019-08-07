{ stdenv, lib, buildGoPackage, fetchFromGitHub  }:

buildGoPackage rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.2.0";

  goPackagePath = "github.com/tektoncd/cli";
  buildFlagsArray = let t = "${goPackagePath}/pkg/cmd/version"; in ''
     -ldflags=
       -X ${t}.clientVersion=${version} 
  '';
  src = fetchFromGitHub {
    owner = "tektoncd";
    repo = "cli";
    rev = "v${version}";
    sha256 = "1h7skps9s99dpvz8y39s0qghbyxancvqhc3i5y6sw223vlbcasqk";
  };

  meta = with stdenv.lib; {
    homepage    = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
