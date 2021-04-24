{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule rec {
  pname = "kiln";
  version = "2021-04-24";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "1b7f5b4ab4863217e92995962be67b2c43567bda";
    hash = "sha256-nzgIwYzNkf7dHO7xIChBVCVX3PMbsAObzLiOyOKpSZQ=";
  };

  vendorSha256 = "sha256-nNK1Hv3MiD1XbYw5aqjk4AmFdN3LHCvUIFHEX75Ox0Y=";

  meta = with lib; {
    description = "A simple static site generator for Gemini";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
