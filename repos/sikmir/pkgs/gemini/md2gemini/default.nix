{ lib, fetchFromGitHub, python3Packages, cjkwrap }:

python3Packages.buildPythonApplication rec {
  pname = "md2gemini";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "makeworld-the-better-one";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-DQH7/wn6chgsDAclXaqHM37sT2aw6RMByCZ9/UPx0Zc=";
  };

  propagatedBuildInputs = with python3Packages; [
    (mistune.overrideAttrs (old: rec {
      pname = "mistune";
      version = "2.0.0a6";
      src = fetchPypi {
        inherit pname version;
        sha256 = "1jaf4dksxywaprc9svazhxsknjj15hxxji2xsbfx435mdyqwnisp";
      };
    }))
    cjkwrap
    wcwidth
  ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "File converter from Markdown to Gemini";
    inherit (src.meta) homepage;
    license = licenses.lgpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
