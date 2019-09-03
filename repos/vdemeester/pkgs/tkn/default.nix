{ stdenv, lib, buildGo111Package, fetchFromGitHub  }:

buildGo111Package rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.3.0";

  goPackagePath = "github.com/tektoncd/cli";
  buildFlagsArray = let t = "${goPackagePath}/pkg/cmd/version"; in ''
     -ldflags=
       -X ${t}.clientVersion=${version} 
  '';
  src = fetchFromGitHub {
    owner = "tektoncd";
    repo = "cli";
    rev = "v${version}";
    sha256 = "11s5qwj5s3ybakdl53hk75f4894588z25863wrd12i22fmxls0aq";
  };

  meta = with stdenv.lib; {
    homepage    = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
