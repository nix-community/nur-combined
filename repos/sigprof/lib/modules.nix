{nixpkgs, ...}: let
  inherit (builtins) isAttrs isPath isString replaceStrings;
  inherit (nixpkgs.lib.attrsets) attrValues filterAttrs listToAttrs nameValuePair optionalAttrs recursiveUpdate;
  inherit (nixpkgs.lib.strings) removePrefix removeSuffix;
  inherit (nixpkgs.lib.trivial) isFunction setFunctionArgs functionArgs;

  # Check whether the module is already imported (the module system can perform
  # `import` itself, therefore strings and paths can also be passed instead of
  # modules).  The test is what `lib.collectModules` does internally.
  #
  isAlreadyImported = module: isFunction module || isAttrs module;

  # Get the module file for the module.
  #
  # Arguments:
  # - `module`: The module.  In order for this function to return anything
  #   useful, this value should be a path or a string pointing to the module
  #   implementation; passing an attribute set or a function will result in
  #   this function returning `null`.
  #
  # Returns `null` if the module file cannot be determined, or the module file
  # as a path or a string.
  #
  getModuleFile = module:
    if isAlreadyImported module
    then null
    else if isPath module || isString module
    then module
    else toString module;

  # Get the `key` value for the module.  This is the value that is used for the
  # `disabledModules` feature.
  #
  # Arguments:
  # - `file`: module file (as a path or a string) or `null`.
  #
  # Returns:
  # - `null` if `file` is `null`;
  # - `file` if `file` is a path;
  # - an attribute set with a `__toString` function if `file` is something else
  #   (this is used to circumvent the `isString` check in the module system
  #   which would otherwise prepend `modulesPath` to the value).`
  #
  getModuleKey = file:
    if file == null
    then null
    else if isPath file
    then file
    else {__toString = _: toString file;};

  # Wrap a module to pass local arguments to the module implementation.  Also
  # provides the `_file` attribute for proper error reporting and the `key`
  # attribute to make the `disabledModules` feature work.
  #
  # Arguments are passed as a set with the following attributes:
  # - `module` (required): The module to wrap; ideally this should be a path,
  #   but a string, function or attribute set would also be acceptable with
  #   some functionality loss.
  # - `localArgs` (optional, defaults to `{}`): The attribute set with local
  #   arguments that would be passed to `module` if it ends up being a
  #   function.  These local arguments will be hidden from the module system,
  #   and the values specified in `localArgs` will override any arguments with
  #   the same names passed by the module system.
  # - `file` (optional): The file containing the module implementation.  Can be
  #   omitted if `module` is a path or a string, otherwise should contain a
  #   path or a string that would be useful to show in an error message
  #   pointing to the module.
  # - `key` (optional): The `key` attribute for the module.  Can be omitted if
  #   `file` is either inferred from `module` (in case `module` is a path or a
  #   string) or specified explicitly.
  #
  # Returns the wrapped module, which will always be an attribute set if at
  # least one of `file` or `key` arguments were either specified or inferred
  # from `module` (the attribute set will then contain the `_file` and `key`
  # attributes corresponding to the argument values, and the real module will
  # be in the `imports` attribute).
  #
  wrapModule = {
    module,
    localArgs ? {},
    file ? getModuleFile module,
    key ? getModuleKey file,
  }: let
    realModule =
      if isAlreadyImported module
      then module
      else import module;
    moduleWithArgs =
      if localArgs != {} && isFunction realModule
      then let
        addArgsWrapper = origArgs @ {...}: realModule (origArgs // localArgs);
        filteredArgs = filterAttrs (n: _: !(localArgs ? ${n})) (functionArgs realModule);
      in
        setFunctionArgs addArgsWrapper filteredArgs
      else realModule;
  in
    if file != null || key != null
    then
      {imports = [moduleWithArgs];}
      // optionalAttrs (file != null) {_file = file;}
      // optionalAttrs (key != null) {inherit key;}
    else moduleWithArgs;

  # The default implementation of the `relativePathToExportedName` function
  # used by `exportModules`.
  #
  # Arguments:
  # - `relativePath`: A string containing the relative path to the module file.
  #
  # Returns a string which would be suitable as an attribute name, so that the
  # module may be added to an attribute set like the `nixosModules` flake
  # output.  This implementation creates the attribute name by removing the
  # `.nix` suffix and then replacing all `/` characters with `-`.
  #
  defaultRelativePathToExportedName = relativePath:
    replaceStrings ["/"] ["-"] (removeSuffix ".nix" relativePath);

  # Create an attribute set of modules suitable for exporting from a flake,
  # e.g., as `nixosModules`.
  #
  # Arguments are passed as a set with the following attributes:
  # - `dir` (required): Path to the directory which contains the module files.
  # - `modules` (required): A list of modules, where each element must have one
  #   of the following forms:
  #   - a path to the file (or a directory with `default.nix`) containing the
  #     module implementation (the path must point inside the directory
  #     specified in `dir`);
  #   - a string which contains the relative path from `dir` to the file (or a
  #     directory with `default.nix`) containing the module implementation;
  #   - a name-value pair (a set with the `name` and `value` attributes), where
  #     `name` is a string which specifies the name for the module in the
  #     exported set, and `value` is the module to be exported (any value which
  #     is supported by the module system).
  # - `localArgs` (optional, defaults to `{}`): The attribute set with local
  #   arguments that would be passed to all modules specified in `modules`.
  #   These local arguments will be hidden from the module system, and the
  #   values specified in `localArgs` will override any arguments with the same
  #   names passed by the module system if that ever happens due to some name
  #   collision.
  # - `mergedModuleName` (optional, defaults to `null`): If this argument is
  #   specified, a module which imports all modules listed in `modules` will be
  #   created and added to the returned attribute set with the specified name.
  # - `relativePathToExportedName` (optional, defaults to
  #   `defaultRelativePathToExportedName`): The function which takes the
  #   relative path from `dir` to the module file and returns the name under
  #   which the module should be added to the returned attribute set.  The
  #   default implementation removes the `.nix` suffix from file names and then
  #   replaces all `/` characters with `-` (this may cause collisions when the
  #   file names also contain `-`, so the module file names should be chosen to
  #   avoid that issue).
  # - `namePrefix` (optional, defaults to `""`): An additional prefix which
  #   will be added to the generated names of modules listed in `modules`.
  #   Applied to the result of `relativePathToExportedName`.  Names for modules
  #   specified as name-value pairs won't have `namePrefix` added; the name
  #   specified in `mergedModuleName` will also be left unmodified.
  #
  # Returns an attribute set with all modules listed in `modules` imported and
  # wrapped to get `localArgs` passed to them.  If the `mergedModuleName`
  # argument was specified, the attribute set will also contain a module which
  # imports all modules listed in `modules` with the name specified in
  # `mergedModuleName`.
  #
  exportModules = {
    dir,
    modules,
    localArgs ? {},
    mergedModuleName ? null,
    relativePathToExportedName ? defaultRelativePathToExportedName,
    namePrefix ? "",
  }: let
    exportOneModule = moduleArg: let
      module =
        if isAttrs moduleArg
        then moduleArg.value
        else if isPath moduleArg
        then moduleArg
        else dir + "/${module}";
      name =
        if isAttrs moduleArg
        then moduleArg.name
        else let
          relativePath = removePrefix ((toString dir) + "/") (toString module);
        in
          namePrefix + (relativePathToExportedName relativePath);
    in
      nameValuePair name (wrapModule {inherit module localArgs;});
    exportedModules = listToAttrs (map exportOneModule modules);
  in
    exportedModules
    // {
      ${mergedModuleName} = {
        imports = attrValues exportedModules;
      };
    };

  # Wrap the specified flake-local modules and create an attribute set suitable
  # for exporting from a flake, e.g., as `nixosModules`.  This is a convenience
  # wrapper for `exportModules` to make its usage in a flake easier.
  #
  # Flake-local modules are expected to have the `flake` argument, the value of
  # which will be a set with the following attributes:
  # - `self`: The flake containing the modules (the value of the `flake`
  #   argument passed to `exportFlakeLocalModules`).
  # - `inputs`: Equivalent to `self.inputs` (added for convenience).
  # - `modules`: The attribute set containing all modules imported by this
  #   invocation of `exportFlakeLocalModules` (the same as the return value of
  #   this function).
  #
  # Using `flake.self` or `flake.modules` in the implementation of flake-local
  # modules requires care to avoid infinite recursion.
  #
  # Arguments:
  # - `flake`: The flake containing the modules (should be bound to the `self`
  #   argument of the `outputs` function of the flake).
  # - `args`: The attribute set with the arguments for the `exportModules`
  #   function.  This set gets modified to add the `flake` module argument
  #   described above to the `extraArgs` attribute (`lib.recursiveUpdate` is
  #   used for modifications, so adding extra attributes to the value of the
  #   `flake` module argument is possible).
  #
  # Return an attribute set with all specified modules imported and wrapped, as
  # described in the documentation of `exportModules`.
  #
  exportFlakeLocalModules = flake: args: let
    modules = exportModules (recursiveUpdate args {
      localArgs.flake = {
        self = flake;
        inputs = flake.inputs;
        inherit modules;
      };
    });
  in
    modules;
in {
  modules = {
    inherit wrapModule defaultRelativePathToExportedName exportModules exportFlakeLocalModules;
  };
}
