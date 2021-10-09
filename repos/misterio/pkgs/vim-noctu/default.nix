{ lib, vimUtils, fetchFromGitHub, ... }:

with lib;

vimUtils.buildVimPlugin {
  pname = "vim-noctu";
  version = "1.8.0";
  src = fetchFromGitHub {
    owner = "noahfrederick";
    repo = "vim-noctu";
    rev = "de2ff9855bccd72cd9ff3082bc89e4a4f36ea4fe";
    sha256 = "sha256-fiMYfRlm/KiMQybL97RcWy3Y+0qim6kl3ZkBvCuv4ZM=";
  };
  meta.homepage = "https://github.com/noahfrederick/vim-noctu";
}
