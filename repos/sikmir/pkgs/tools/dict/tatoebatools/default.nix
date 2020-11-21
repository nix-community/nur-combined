{ lib, python3Packages, sources, withCli ? true }:

python3Packages.buildPythonApplication {
  pname = "tatoebatools-unstable";
  version = lib.substring 0 10 sources.tatoebatools.date;

  src = sources.tatoebatools;

  propagatedBuildInputs = with python3Packages; [ beautifulsoup4 pandas requests tqdm ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_iter_with_file"
    "test_update_sentences_detailed"
    "test_update_links"
    "test_update_queries"
    "test_update_up_to_date"
    "test_update_with_not_language_pair"
  ];

  meta = with lib; {
    inherit (sources.tatoebatools) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
