{ zluda, fetchFromGitHub, ... }:
zluda.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = "zluda-lshqqytiger";
    src = fetchFromGitHub {
      owner = "lshqqytiger";
      repo = "ZLUDA";
      rev = "rel.2ad9ad6851c3c38167519ca04a4d36e7bd96dce0";
      hash = "sha256-lykM18Ml1eeLMj/y6uPk34QOeh7Y59i1Y0Nr118Manw=";
      fetchSubmodules = true;
    };
  }
)
