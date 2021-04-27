{ lib, python3Packages, fetchFromGitHub, withCli ? true, checkLang ? false }:

python3Packages.buildPythonApplication rec {
  pname = "tatoebatools";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "LBeaudoux";
    repo = pname;
    rev = "c3b4e40886233a83e30a517d63a1eee0547650d7";
    hash = "sha256-clKZPQeDFUPlkyLnSeZkYdz1sOwIWeV3L1KOQOE7J8E=";
  };

  patches = lib.optional (!checkLang) ./dont-check-lang-validity.patch
    ++ lib.optional withCli ./cli.patch;

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 pandas requests setuptools tqdm ]
    ++ lib.optionals withCli [ click xdg ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = lib.optionals (!checkLang) [
    "test_init_with_not_language_1"
    "test_init_with_not_language_2"
  ];

  meta = with lib; {
    description = "A library for downloading, updating and iterating over data files from Tatoeba";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
