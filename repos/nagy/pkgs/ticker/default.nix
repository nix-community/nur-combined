{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "ticker";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "1r2q7iq5xa7rivlqpklp6iiynn5b8iqs7j43j4mwypj010vm1nq1";
  };

  vendorSha256 = "0k1jrq1b2696ckd764w44hzck9lpcfxpjc7lhi0805lkzcmkwk7h";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3;
  };
}
