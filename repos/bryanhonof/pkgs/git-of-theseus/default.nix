{
  lib,
  fetchFromGitHub,
  python3Packages,
  git,
}:

python3Packages.buildPythonApplication {
  pname = "git-of-theseus";
  version = "0.3.4";
  pyproject = true;

  # Upstream stopped tagging after v0.2.0; this is the "bump to 0.3.4" commit.
  src = fetchFromGitHub {
    owner = "erikbern";
    repo = "git-of-theseus";
    rev = "1d77f082a9b25fb3a0c541641722cd4836135362";
    hash = "sha256-PUCZjMgTgAB996AsDDJXS8uCpR5Q1W2cECGV4htjhKI=";
  };

  build-system = with python3Packages; [ setuptools ];

  # python-dateutil and scipy are used but undeclared upstream; scipy only by
  # the survival plot's --exp-fit.
  dependencies = with python3Packages; [
    gitpython
    matplotlib
    numpy
    pygments
    python-dateutil
    scipy
    tqdm
    wcmatch
  ];

  # GitPython drives the git CLI.
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ git ])
  ];

  pythonImportsCheck = [ "git_of_theseus" ];

  meta = with lib; {
    description = "Analyze how a Git repo grows over time";
    homepage = "https://github.com/erikbern/git-of-theseus";
    license = licenses.asl20;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.unix;
    mainProgram = "git-of-theseus-analyze";
  };
}
