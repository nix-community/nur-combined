{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "ticker";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "1b1sf7gqgvdr28d2d6cnr1dav7dncb5b2l6425l71n08l6hs31lk";
  };

  vendorSha256 = "0k1jrq1b2696ckd764w44hzck9lpcfxpjc7lhi0805lkzcmkwk7h";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3;
  };
}
