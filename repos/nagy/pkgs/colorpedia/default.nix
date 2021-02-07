{ lib, fetchPypi, python3Packages, setuptools, setuptools_scm, fire, toml
, installShellFiles }:

python3Packages.buildPythonApplication rec {
  pname = "colorpedia";
  version = "1.2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1b19mlss6arc4sk0bsk6ssqc6advnzr2kq7snxrv8a6hki81ykm5";
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
    maintainers = [ ];
  };
}
