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
  version = "0.1.0";
  minimumOcamlVersion = "4.10";

  src = fetchFromGitHub {
    owner = "smabie";
    repo = "xs";
    rev = "6b5d6333f6e5f752651f7f8df23fcb1899108071";
    sha256 = "13qm9df8vx9bic4iyp6v5vshajrc7lis9dc2f5ais8nqqqhlhcvg";
  };

  useDune2 = true;
  buildInputs = with opkgs; [ res core angstrom ppx_jane ppx_inline_test ];
  doCheck = true;

  meta = with stdenv.lib; {
    description = "Concatenative array language inspired by kdb/+q";
    homepage = "https://github.com/smabie/xs";
    platforms = platforms.unix;
    license = null; # no license yet
  };
}

