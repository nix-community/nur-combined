{
  lib,
  fetchPypi,
  buildPythonApplication,
  setuptools,
  setuptools-scm,
  fire,
  installShellFiles,
}:

buildPythonApplication rec {
  pname = "colorpedia";
  version = "1.2.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-NNF3Zqvt30lfrsw6ZfHnTa0Neo/Qdx9Vw7zrQJLfQgU=";
  };

  nativeBuildInputs = [
    setuptools-scm
    installShellFiles
  ];

  propagatedBuildInputs = [
    fire
    setuptools
  ];

  pythonImportsCheck = [ "colorpedia" ];

  postInstall = ''
    installShellCompletion --cmd color \
           --bash <($out/bin/color -- --completion) \
           --zsh <($out/bin/color -- --completion | sed "s/:/: /g")
    installShellCompletion --cmd colorpedia \
           --bash <($out/bin/colorpedia -- --completion) \
           --zsh <($out/bin/colorpedia -- --completion | sed "s/:/: /g")
  '';

  meta = with lib; {
    description = "Command-line tool for looking up colors and palettes";
    homepage = "https://joowani.github.io/colorpedia/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
