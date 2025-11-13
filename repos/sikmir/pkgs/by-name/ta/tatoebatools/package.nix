{
  lib,
  python3Packages,
  fetchFromGitHub,
  withCli ? true,
  checkLang ? false,
}:

python3Packages.buildPythonApplication rec {
  pname = "tatoebatools";
  version = "0.2.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "LBeaudoux";
    repo = "tatoebatools";
    tag = "v${version}";
    hash = "sha256-45CDAH80z6zApgR4gK7ZLPSXtCyPx+6YaA61Iskued4=";
  };

  patches =
    lib.optional (!checkLang) ./dont-check-lang-validity.patch ++ lib.optional withCli ./cli.patch;

  build-system = with python3Packages; [ setuptools ];

  dependencies =
    with python3Packages;
    [
      beautifulsoup4
      pandas
      requests
      sqlalchemy
      setuptools
      tqdm
    ]
    ++ lib.optionals withCli [
      click
      xdg-base-dirs
    ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = lib.optionals (!checkLang) [
    "test_init_with_not_language_1"
    "test_init_with_not_language_2"
  ];

  meta = {
    description = "A library for downloading, updating and iterating over data files from Tatoeba";
    homepage = "https://github.com/LBeaudoux/tatoebatools";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
