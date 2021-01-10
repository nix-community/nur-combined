{ lib
, pkgs
, nodejs
, stdenv
, linkFarm
, fetchzip
, buildPythonPackage
, fetchFromGitHub
, nltk
, mock
, pytestCheckHook
}:

let
  acceptance_tests = (import ./acceptance_tests/node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  }).package;

  nltk_data_rev = "3a486db7729373e7982eda3f7e6e6572c532d06c";
  nltk_data = linkFarm "nltk_data" [
    {
      name = "corpora/stopwords";
      path = fetchzip {
        url = "https://github.com/nltk/nltk_data/raw/${nltk_data_rev}/packages/corpora/stopwords.zip";
        sha256 = "08kzi6ajf2lc5bg4d9yq2qg5z931vc6ss983hcbaqx90dx4zbd4c";
      };
    }
  ];
in buildPythonPackage rec {
  pname = "lunr.py";
  version = "0.5.9";

  src = fetchFromGitHub {
    owner = "yeraydiazdiaz";
    repo = pname;
    rev = version;
    sha256 = "1410rnyjs0z48rd4k6bwjmr51y7kfcylpka5k5faqf2in74wb0lx";
  };

  patches = [
    ./loosen-requirements.patch
  ];

  propagatedBuildInputs = [
    nltk
  ];

  checkInputs = [
    mock
    nodejs
    pytestCheckHook
  ];

  # Patch in node_modules & nltk_data for tests
  preCheck = ''
    ln -s ${acceptance_tests}/lib/node_modules/acceptance_tests/node_modules tests/acceptance_tests/javascript
    export NLTK_DATA=${nltk_data}
  '';

  meta = with lib; {
    description = "A Python implementation of Lunr.js";
    homepage = "https://github.com/yeraydiazdiaz/lunr.py";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
  };
}
