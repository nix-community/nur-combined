{ modules ? { }, reexports ? { }, ... } @ baseSelf: baseSelf // rec {
  extension = lib: libSuper:
    let moduleArg = { inherit lib libSuper; }; in
    builtins.mapAttrs (name: module:
      libSuper.${name} or { } // module moduleArg
    ) modules // reexports moduleArg;
  standalone' = libSuper: let
      # An actual lib is provided instead of { } because of basic
      # top-level import evaluation in modules like lib.licenses.
      dummyModuleArg = { lib = libSuper; inherit libSuper; };
      lib = libSuper.extend extension;
    in {
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
