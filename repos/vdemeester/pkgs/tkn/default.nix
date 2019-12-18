{ stdenv, lib, buildGoModule, fetchFromGitHub  }:

buildGoModule rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.6.0";

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
    sha256 = "15x3gr97r45br7j38lg6vr39nwxds5rz16mf7j85wi2zszkbn0ri";
  };
  modSha256 = "1mfr34nfbgr7dv3iqcwiqbivbdhl2likwhcr3w4dvg79crms4fvs";

  meta = with stdenv.lib; {
    homepage    = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
