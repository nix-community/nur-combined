{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage {
  pname = "wikitextprocessor";
  version = "0.4.96";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = "wikitextprocessor";
    rev = "3fa4cb9418e05d1d462a53d629848196b7ade492";
    hash = "sha256-cjhKgzqsPwVO2/fwC62IDilMhz6fg6qQrnm0xLQ3KPk=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    lupa
    dateparser
    lru-dict
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests =
    [ "test_string_format2" ]
    ++ lib.optionals stdenv.isDarwin [
      "test_long_twothread"
      "test_expr29"
    ];

  doCheck = false;

  meta = {
    description = "Parser and expander for Wikipedia, Wiktionary etc. dump files, with Lua execution support";
    homepage = "https://github.com/tatuylonen/wikitextprocessor";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
