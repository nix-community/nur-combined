{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "gemget";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "makeworld-the-better-one";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ma07wlki4pgmw19yk4dzyxa6blk8ciz3wb46ipbfz7k361lhsry";
  };

  vendorSha256 = "1dfv40jljs6m9c4m0njm23lg9anr2lzyzyw20ddi3brfk008g7hj";

  meta = with lib; {
    description = "Command line downloader for the Gemini protocol";
    homepage = "https://github.com/makeworld-the-better-one/gemget";
    license = with licenses; [ mit ];
  };
}
