{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gocov";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "axw";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uydYBPkQZXyz7gn7y4Eac8yrCTDv0376/2HAcJdaupE=";
  };

  vendorHash = "sha256-IfLfPDGtH+I0D8oIfKsLvz8F2ef5SRs4+MhCrVGQbsI=";

  meta = with lib; {
    description = "Coverage testing tool for The Go Programming Language.";
    longDescription = ''
      Coverage testing tool for The Go Programming Language.
    '';
    license = licenses.mit;
    broken = false;
    maintainers = with maintainers; [ mpoquet ];
    platforms = platforms.all;
    homepage = "https://github.com/axw/gocov";
  };
}
