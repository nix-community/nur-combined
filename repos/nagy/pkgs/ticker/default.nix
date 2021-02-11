{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "ticker";
  version = "3.0.7";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "0kk892fq6zf516mxnf36b2nif1l1xzg4inchqhznp7sg0w6ysmjp";
  };

  vendorSha256 = "0k1jrq1b2696ckd764w44hzck9lpcfxpjc7lhi0805lkzcmkwk7h";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3;
  };
}
