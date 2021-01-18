{ lib, python3Packages, sources, cjkwrap }:

python3Packages.buildPythonApplication {
  pname = "md2gemini-unstable";
  version = lib.substring 0 10 sources.md2gemini.date;

  src = sources.md2gemini;

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
    inherit (sources.md2gemini) description homepage;
    license = licenses.lgpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
