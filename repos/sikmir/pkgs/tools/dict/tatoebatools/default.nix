{ lib, python3Packages, sources, withCli ? true, checkLang ? false }:

python3Packages.buildPythonApplication {
  pname = "tatoebatools-unstable";
  version = lib.substring 0 10 sources.tatoebatools.date;

  src = sources.tatoebatools;

  patches = lib.optional checkLang ./dont-check-lang-validity.patch
    ++ lib.optional withCli ./cli.patch;

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 pandas requests setuptools tqdm ]
    ++ lib.optionals withCli [ click xdg ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = lib.optionals checkLang [
    "test_init_with_not_language_1"
    "test_init_with_not_language_2"
  ];

  meta = with lib; {
    inherit (sources.tatoebatools) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
