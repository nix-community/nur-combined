# subdl with "--utf8" option (chardet)

{ lib, fetchFromGitHub, python3 }:

python3.pkgs.buildPythonApplication {
  pname = "subdl";
  version = "unstable-2022-09-09";
  src = fetchFromGitHub {
    owner = "alexanderwink";
    repo = "subdl";
    rev = "da2398546c33da1665dbc2d985b30d959c6f5a0c";
    sha256 = "sha256-YI1lTBKb5tHDXVbOoEE+Y0JKYusV1mbbj/xyq8y2Qak=";
  };
  propagatedBuildInputs = [
    python3.pkgs.chardet
  ];
  meta = {
    homepage = "https://github.com/alexanderwink/subdl";
    description = "A command-line tool to download subtitles from opensubtitles.org";
    platforms = lib.platforms.all;
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.exfalso ];
  };
}
