{ lib, buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "ticker";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = pname;
    rev = "v${version}";
    sha256 = "0cyp29qng0pbp2xlbj172pmrkvv24l07k1spqw99m7724bg28i2c";
  };

  vendorSha256 = "12gkwqkf7xxgc3ckra7ar6n4klykja43ya0s1j0ds3pinyrhvc5b";

  subPackages = [ "." ];

  meta = with lib; {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    license = licenses.gpl3;
  };
}
