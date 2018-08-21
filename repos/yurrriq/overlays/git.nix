self: super: rec {

  gitAndTools = super.gitAndTools // {
    inherit (super) git-crypt lab sourcetree;
  };

}
