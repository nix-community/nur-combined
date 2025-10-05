{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  curl,
  openssl,
  beautifulsoup4,
  brotli,
  cssutils,
  cryptography,
  defusedxml,
  flask,
  python-dotenv,
  requests,
  stem,
  validators,
  waitress,
  nix-update-script,
}:
buildPythonApplication rec {
  pname = "whoogle-search";
  version = "1.1.0";
  pyproject = true;
  dontCheckRuntimeDeps = true;

  src = fetchFromGitHub {
    owner = "benbusby";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-AnLGOXVaaT//u3BEsJ2T4Of9O6fKekwCpIdDiS43l2c=";
  };

  pypaBuildFlags = [ "--sdist" ];

  makeWrapperArgs = [
    "--suffix PATH : ${
      lib.makeBinPath [
        curl
        openssl
      ]
    }"
  ];

  postPatch = ''
    for file in app/static/js/*.js; do
      hash=$(md5sum $file | cut -c1-8)
      cp $file "app/static/build/$(basename $file .js).$hash.js"
    done
    for file in app/static/css/*.css; do
      hash=$(md5sum $file | cut -c1-8)
      cp $file "app/static/build/$(basename $file .css).$hash.css"
    done
  '';

  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    brotli
    cssutils
    cryptography
    defusedxml
    flask
    python-dotenv
    requests
    stem
    validators
    waitress
  ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A self-hosted, ad-free, privacy-respecting metasearch engine";
    homepage = "https://github.com/benbusby/whoogle-search";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ataraxiasjel ];
    mainProgram = "whoogle-search";
  };
}
