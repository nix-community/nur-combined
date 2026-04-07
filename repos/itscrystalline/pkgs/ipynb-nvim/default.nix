{
  lib,
  vimUtils,
  fetchFromGitHub,
  python3,
}:
vimUtils.buildVimPlugin rec {
  pname = "ipynb-nvim";
  version = "1.6.6";

  src = fetchFromGitHub {
    owner = "ansh-info";
    repo = "ipynb.nvim";
    rev = "v${version}";
    hash = "sha256-L8g4GhZ4b0b8XzyEBdVDparWmTZ0yxNO+Sx/t+wVqj8=";
  };

  pythonEnv = python3.withPackages (ps:
    with ps; [
      ipykernel
      jupyter-client
      nbformat
    ]);

  postInstall = ''
    mkdir -p $out/python/.venv/bin
    ln -s ${pythonEnv}/bin/python $out/python/.venv/bin/python
    ln -s ${pythonEnv}/bin/python3 $out/python/.venv/bin/python3
  '';

  meta = with lib; {
    description = "Neovim plugin for editing Jupyter notebooks (.ipynb) natively with Colab-style cell rendering";
    homepage = "https://github.com/ansh-info/ipynb.nvim";
    license = licenses.mit;
    sourceProvenance = [sourceTypes.fromSource];
    maintainers = [];
  };
}
