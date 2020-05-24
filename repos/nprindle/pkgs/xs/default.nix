{ stdenv, fetchFromGitHub
, ocamlPackages
}:

let
  opkgs = ocamlPackages.overrideScope' (self: super: {
    res = super.buildDunePackage {
      pname = "res";
      version = "4.0.7";
      minimumOcamlVersion = "4.10";
      src = fetchFromGitHub {
        owner = "mmottl";
        repo = "res";
        rev = "042016305aacf7864619e8a04a8a4f404a2d71d0";
        sha256 = "09yylq5j3vhsfdv7prlxy8iq5kapxg4mql0f4ir347l5f7086dx8";
      };
      doCheck = true;
    };
  });
in opkgs.buildDunePackage {
  pname = "xs";
  version = "unstable-2020-05-21";
  minimumOcamlVersion = "4.10";

  src = fetchFromGitHub {
    owner = "smabie";
    repo = "xs";
    rev = "c41fbee63895570e01a0943ea4924c362e932273";
    sha256 = "1d5gwjca8cgq3qljmrmsh3zi4ksiqz141s9lcni584cn75ivp50v";
  };

  useDune2 = true;
  buildInputs = with opkgs; [ res core angstrom ppx_jane ppx_inline_test ];
  doCheck = true;

  meta = with stdenv.lib; {
    description = "Concatenative array language inspired by kdb/+q";
    homepage = "https://github.com/smabie/xs";
    platforms = platforms.unix;
    license = licenses.publicDomain;
    broken = true;
  };
}

