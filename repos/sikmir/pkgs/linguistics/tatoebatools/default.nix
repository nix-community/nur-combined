{ lib, stdenv, python3Packages, fetchFromGitHub, withCli ? true, checkLang ? false }:

python3Packages.buildPythonApplication rec {
  pname = "tatoebatools";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "LBeaudoux";
    repo = "tatoebatools";
    rev = "v${version}";
    hash = "sha256-/xg57VYlrdfJV/6uvWsb+6OE5Hl4Vb9pukC5IvYRhoA=";
  };

  patches = lib.optional (!checkLang) ./dont-check-lang-validity.patch
    ++ lib.optional withCli ./cli.patch;

  postPatch = "sed -i 's/==.*\"/\"/;s/>=.*\"/\"/' setup.py";

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 pandas requests sqlalchemy setuptools tqdm ]
    ++ lib.optionals withCli [ click xdg-base-dirs ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = lib.optionals (!checkLang) [
    "test_init_with_not_language_1"
    "test_init_with_not_language_2"
  ];

  meta = with lib; {
    description = "A library for downloading, updating and iterating over data files from Tatoeba";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
