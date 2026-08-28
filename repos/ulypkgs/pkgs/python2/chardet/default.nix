{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  pytest,
  pytest-runner,
  hypothesis,
}:

buildPythonPackage (finalAttrs: {
  pname = "chardet";
  version = "3.0.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-hKuS7RxNTxaRbgWQa2t1psD7XbghzGXnDL1ko+Kl6q4=";
  };

  patches = [
    # Add pytest 4 support. See: https://github.com/chardet/chardet/pull/174
    (fetchpatch {
      url = "https://github.com/chardet/chardet/commit/0561ddcedcd12ea1f98b7ddedb93686ed8a5ffa4.patch";
      hash = "sha256-WNjctETskgvNRZZh4QQfjqSzOXwXle90wrBlMZyEPfg=";
    })
  ];

  checkInputs = [
    pytest
    pytest-runner
    hypothesis
  ];

  meta = with lib; {
    homepage = "https://github.com/chardet/chardet";
    description = "Universal encoding detector";
    license = licenses.lgpl2;
    maintainers = with maintainers; [ domenkozar ];
  };
})
