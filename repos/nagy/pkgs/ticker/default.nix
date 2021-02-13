{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "ticker";
  version = "3.0.10";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "0pqh58gskxff2dpx1xhghbza5p54lb1ynhajs9ivr9g250aqfnh9";
  };

  vendorSha256 = "0k1jrq1b2696ckd764w44hzck9lpcfxpjc7lhi0805lkzcmkwk7h";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3;
  };
}
