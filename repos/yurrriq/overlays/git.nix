self: super: rec {

  gitAndTools = super.gitAndTools // {
    inherit (super) lab sourcetree;
  };

}
