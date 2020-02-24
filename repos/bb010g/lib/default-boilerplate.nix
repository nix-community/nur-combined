{ modules ? { }, reexports ? { }, ... } @ baseSelf: baseSelf // rec {
  extension = lib: libSuper:
    let moduleArg = { inherit lib libSuper; }; in
    builtins.mapAttrs (name: module:
      libSuper.${name} or { } // module moduleArg
    ) modules // reexports moduleArg;
  standalone' =
    let dummyModuleArg = { lib = { }; libSuper = { }; }; in
    libSuper:
    let lib = libSuper.extend extension; in {
      modules = builtins.mapAttrs (name: module:
        let libModule = lib.${name}; in
        builtins.mapAttrs (attrName: dummyValue:
          libModule.${attrName}
        ) (module dummyModuleArg)
      ) modules;
      reexports = reexports { inherit lib libSuper; };
    };
  standaloneModules = libSuper: (standalone' libSuper).modules;
  standaloneReexports = libSuper: (standalone' libSuper).reexports;
  standalone = libSuper:
    let standaloneLib = standalone' libSuper; in
    standaloneLib.modules // standaloneLib.reexports;
}
