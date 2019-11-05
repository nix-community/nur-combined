{ stdenv, lib, buildGoModule, fetchFromGitHub  }:

buildGoModule rec {
  pname = "tkn";
  name = "${pname}-${version}";
  version = "0.4.0";

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
    sha256 = "00851p3mky3rgv0yqhdmj6kvp2ih1z3inkp668851fsscajswkb1";
  };
  modSha256 = "0yhmbfp3nnk92p07g2nmw31n0ima8yh1951llrw9wgjdlnr33klp";

  meta = with stdenv.lib; {
    homepage    = https://github.com/tektoncd/cli;
    description = "A CLI for interacting with Tekton!";
    license     = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
  };
}
