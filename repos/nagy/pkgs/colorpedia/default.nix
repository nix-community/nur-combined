{ lib, fetchPypi, python3Packages, setuptools, setuptools_scm, fire, toml
, installShellFiles }:

python3Packages.buildPythonApplication rec {
  pname = "colorpedia";
  version = "1.2.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "01a2vy941sxwqdaiyxyhixx0vbadwzqnafncmrglkpzdmdk7gl9l";
  };

  nativeBuildInputs = [ setuptools_scm installShellFiles ];

  propagatedBuildInputs = [ fire toml setuptools ];

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
