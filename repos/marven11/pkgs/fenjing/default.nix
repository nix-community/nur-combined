{ pkgs, stdenv }:

with pkgs.python3Packages;
buildPythonPackage rec {
  pname = "fenjing";
  # it takes minutes
  doCheck = false;

  nativeBuildInputs = [ pkgs.installShellFiles ];

  build-system = [ setuptools setuptools-scm ];

  dependencies = [
    requests
    beautifulsoup4
    click
    flask
    jinja2
    prompt-toolkit
    pygments
    pysocks
    rich
  ];

  postInstall = ''
    installShellCompletion --cmd fenjing \
      --bash <(_FENJING_COMPLETE=bash_source $out/bin/fenjing) \
      --fish <(_FENJING_COMPLETE=fish_source $out/bin/fenjing) \
      --zsh <(_FENJING_COMPLETE=zsh_source $out/bin/fenjing) \
  '';

  src = pkgs.fetchFromGitHub {
    owner = "Marven11";
    repo = "Fenjing";
    rev = "v0.8.0";
    sha256 = "sha256-K6d85aTKrCE6sJUJvJSJWvr27iv/z7tybb7SBsgF5Wg=";
  };
  version = "0.8.0";
}
