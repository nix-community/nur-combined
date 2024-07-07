{ pkgs ? import <nixpkgs> {} }:
let
  customPython = pkgs.python3.buildEnv.override {
    extraLibs = with pkgs.python3Packages; [
      dateutil
      packaging
      requests
    ];
  };
in
with pkgs; mkShell {
  buildInputs = [
    customPython
    ripgrep
    rargs
    findutils
  ];
  shellHook = ''
    github(){
      find pkgs -name "default.nix"|rargs rg -l "fetchFromGitHub" {0}|rargs -j$(nproc --all) python update-derivations/update-github-drv.py ~/.config/passwords/github-updater-token {0} 
      # python update-derivations/update-github-drv.py ~/.config/passwords/github-updater-token pkgs/patched-alacritty/default.nix
    }
    gitlab(){
      find pkgs -name "default.nix"|rargs rg -l "fetchFromGitLab" {0}|rargs -j$(nproc --all) python update-derivations/update-gitlab-drv.py {0}
      # python update-derivations/update-gitlab-drv.py pkgs/Killbots/default.nix
    }
    pypi(){
      find pkgs -name "default.nix"|rargs rg -l "fetchPypi" {0}|rargs -j$(nproc --all) python update-derivations/update-pypi-drv.py {0}
    }
    run(){
      github
      gitlab
      pypi
    }
  '';
}

