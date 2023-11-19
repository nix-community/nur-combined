{ lib, buildVimPluginFrom2Nix, fetchFromGitHub }:

# final: prev:
{
  "vim-crystal" = buildVimPluginFrom2Nix {
    name = "vim-crystal";
    src = fetchFromGitHub {
      owner = "vim-crystal";
      repo = "vim-crystal";
      rev = "481195d4a309d7c682315c9f042762bbfb9d5f57";
      sha256 = "1nagmw05sxxfywvkd8xk30hpifyr08f4yl6g6k0xckg282x90wpv";
    };
  };
}
