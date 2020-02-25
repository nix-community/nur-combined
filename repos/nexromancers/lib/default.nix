import ./default-boilerplate.nix {
  modules = { #{{{1
    meta = import ./meta.nix;
    trivial = import ./trivial.nix;
  };
  reexports = { lib, libSuper }: { #{{{1
    inherit (lib.meta) #{{{2
      addMetaAttrs'
      setDrvBroken breakDrv unbreakDrv
    ;

    inherit (lib.trivial) #{{{2
      mapIf
    ;
    #}}}2
  };
  #}}}1
}
# vim:fdm=marker:fdl=1
