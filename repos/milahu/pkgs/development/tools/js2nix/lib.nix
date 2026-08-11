{ lib
, stdenv
, callPackage
, fetchurl
, makeWrapper
, writeScriptBin
, runCommand
, coreutils
, libarchive
, nodejs
, python3
, xcbuild
, nix
, yarn
, node-gyp ? null
}@_args:

let
  stub-node-gyp = msg: writeScriptBin "node-gyp" ''
    >&2 echo
    >&2 echo "  ERROR: ${msg}"
    >&2 echo
    exit 1
  '';

  # We build node-gyp package here if it's not provided by using the version of js2nix 
  # that isn't bound to node-gyp as a dependency.
  #
  node-gyp = _args.node-gyp or (
    let
      buildNodeModule = createBuildNodeModule [

        # Prevent building node-gyp package using node-gyp itself.
        # This shouldn't happen, it's just a generic guard.
        #
        (stub-node-gyp "Unable to build the node-gyp package with node-gyp itself: infinite recursion encountered.")
      ];
      tree = createLoadNixExpression buildNodeModule ./yarn.lock.nix { };

      # node-gyp is added as optionalDependency on the package.json file to explicitly separate it from 
      # dependencies but still have it managed by mechanisms from Yarn package manager, i.e. modify yarn.lock 
      # file to reflect all of node-gyp's dependencies.
      #
      node-gyp-ref = "node-gyp@${(lib.importJSON ./package.json).optionalDependencies.node-gyp}";
    in
    tree.${node-gyp-ref}.overrideAttrs (prev: {
      nativeBuildInputs = prev.nativeBuildInputs ++ [ makeWrapper python3 ];
      postInstall = ''
        patchShebangs $out/lib/gyp
        wrapProgram $out/bin/node-gyp \
          --set npm_config_nodedir ${nodejs} \
          --set npm_config_python "${python3}/bin/python"
      '';
    })
  );

  proxy = runCommand "js2nix-proxy"
    {
      nativeBuildInputs = [ makeWrapper ];
    } ''
    mkdir -p $out/bin
    makeWrapper ${bin}/lib/lib/proxy.js $out/bin/yarn
  '';

  # Links given list of node modules derivations into $out directory.
  #
  linkNodeModules = lib.makeOverridable (
    { name ? ""
    , modules

      # Prefix is peing used to place the resulting dependencies in the resulting derivation output.
      # By default it's a root derivation output folder, however, for some casees it can be useful to
      # provide this prefix. For instance, in case it's required to provide dependency artifact
      # hooked into $NODE_PATH instead of realpath or symlinked folder, as traditional package 
      # managers do. 
      # For example, if it follows the `/lib/node_modules` folder structure that can be picked up by 
      # nodejs setup-hook, see # https://github.com/NixOS/nixpkgs/blob/564f9b1da/pkgs/development/web/nodejs/setup-hook.sh#L2
      #
      #    devNodeModules = js2nix.makeNodeModules ./package.json {
      #      name = "dev";
      #      inherit tree;
      #      prefix = "/lib/node_modules";
      #      exposeBin = true;
      #    };
      #
      # So the /nix/store/23c0002ycx2b0gm69wh0nnka9fbl949l-dev-node-modules/lib/node_modules will be added
      # into $NODE_PATH env var. See the `./README.md` file for more details.

    , prefix ? ""
      # By default, there will be a `$out/.bin` directory if binaries are provided by
      # the modules, but Nix won't add it to the $PATH unlike the `$out/bin` directory. `exposeBin` will
      # link all the binaries provided by the modules in `$out/bin` as well.
      #
      # For example:
      #
      #  let
      #    js2nix = nixpkgs.callPackage ./default.nix {};
      #    tree = js2nix.load ./yarn.lock.nix { };
      #    devNodeModules = js2nix.makeNodeModules ./package.json {
      #      name = "dev";
      #      inherit tree;
      #      prefix = "/lib/node_modules";
      #      exposeBin = true;
      #    };
      #
      #  in nixpkgs.mkShell {
      #    buildInputs = with nixpkgs; [
      #      nodejs
      #      yarn
      #      devNodeModules
      #    ];
      #  }
      #
      # will add the binaries of all the modules in `./package.json#dependencies` to the resulting $PATH, so
      #
      #   nix-shell --run "command -v jest"
      #
      # will give a full path to the `jest` binary.
      #
      # Defaults to `false`.
      #
    , exposeBin ? false
    }:
    let
      commandName =
        if name != "" then "${name}-node-modules" else "node-modules";
      nm = runCommand commandName
        {
          passthru.modules = builtins.fold' (acc: m: acc // { ${m.moduleName} = m; }) { } modules;
        } ''
        mkdir -p $out${prefix}
        pushd $out${prefix} >/dev/null
        ${createLinkNodeModulesScript name modules}
        popd >/dev/null

        ${if exposeBin then ''
          if [[ -d $out${prefix}/.bin ]]; then
            ln -sT $out${prefix}/.bin $out/bin
          fi
        '' else ""}
      '';
    in
    nm
  );

  # This script is run in the node_modules folder and creates symlinks to the given modules and
  # symlinks their binaries in the ./.bin folder. A private function for internal use.
  #
  createLinkNodeModulesScript = name: modules: ''
    mkdir -p ./.bin
    echo "Create node_modules link farm for \"${name}\":" 
    ${lib.concatMapStringsSep "\n" (module:
      let
        hasScope = module.id.scope != "";
        targetFolder = if hasScope then
          "@${module.id.scope}/${module.id.name}"
        else
          module.id.name;
      in ''
        echo " - ${targetFolder}"
        ${lib.optionalString hasScope ''mkdir -p "./@${module.id.scope}"''}
        ln -sT "${module}/lib" "./${targetFolder}"

        pushd ./.bin >/dev/null
        for i in ${module}/bin/*; do
          bname="$(basename $i)"
          ln -s $i || (echo && echo The $i clashes with: && ls -la . | grep $bname && echo)
        done 
        popd >/dev/null
      '') modules}
    echo
  '';

  # Creates an overridable function that creates a derivation of a Node.js module with extra native
  # build inputs that are required by the standard Node.js package build process, such as node-gyp.
  #
  # But why not just buildNodeModule?
  # The reason for that is to be able to bootstrap js2nix itself with a minimum amount of 
  # dependencies and limitations on the build process in order to bootstrap necessary tools later
  # that are required by a standard Node.js package build process and then instantiate itself with
  # the extended toolset that is required for a standard npm package build process. 
  #
  # In particular, the js2nix tool itself can be built without dependency on node-gyp in order to
  # build that build dependency and then instantiate itself with node-gyp in the nativeBuildInputs
  # already.
  #
  createBuildNodeModule = extraNativeBuildInputs: lib.makeOverridable ({ host ? null
                                                                       , id
                                                                       , version
                                                                       , src
                                                                       , modules ? [ ]
                                                                       , lifeCycleScripts ? [ "install" "postinstall" ]
                                                                       , doCheck ? true
                                                                       , ...
                                                                       }@args:
    let
      hasHost = builtins.typeOf host == "set";
      pname = if id.scope == "" then id.name else "${id.scope}-${id.name}";
      moduleName = if id.scope == "" then id.name else "@${id.scope}/${id.name}";
      ref = "${moduleName}@${version}";
    in
    stdenv.mkDerivation ({
      inherit pname version src;
      passthru = { inherit id modules host hasHost moduleName ref; };

      # 'gnutar' doesn't correctly extract archives with files owned by root without
      # the executable bit. You can reproduce the issue by:
      #
      #   src = fetchurl {
      #     url = "https://registry.yarnpkg.com/pngjs/-/pngjs-5.0.0.tgz";
      #     sha1 = "e79dd2b215767fd9c04561c01236df960bce7fbb";
      #   }
      #
      # Whereas 'libarchive' is able to extract such archives so this is why this 
      # override exists.
      #
      unpackCmd = "if test -f $curSrc; then bsdtar xf $curSrc; else false; fi";

      nativeBuildInputs =
        [ nodejs libarchive ]
          ++ extraNativeBuildInputs
          ++ lib.optionals stdenv.isDarwin [ xcbuild ];
      buildInputs = [ nodejs ];

      dontConfigure = true;
      dontBuild = true;

      # Workaround 'permission denied' error for poorly packed archives.
      # See https://discourse.nixos.org/t/unpack-phase-permission-denied/13382/4
      # and https://github.com/Profpatsch/yarn2nix/issues/56#issuecomment-804825097
      #
      dontMakeSourcesWritable = true;
      postUnpack = ''
        # Need to make it generic because some of the packages are packed in different way.
        chmod -R +x "$sourceRoot"
      '';
    } // (if hasHost then {

      # Providing the sources only because the package is going to be hosted, thus for the
      # host it's just a source of a guest package, but not a properly installed one, that
      # would be directly used in a particular node_modules artifact.
      #
      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib
        cp -r . $out/lib
        runHook postInstall 
      '';
    } else {
      installPhase =
        let

          # Creates a JS valid name for the module.
          # For example:
          #   makeJSVarName { scope = ""; name = "lodash.debounce"; } # -> "_lodash_debounce"
          #
          makeJSVarName = { scope, name }:
            builtins.replaceStrings [ "-" "." ] [ "_" "_" ] "_${scope}${name}";

          # Returns JS Promise. Recursivelly traverse the modules in order to call
          # appropriate JS function over it to either link or host a module.
          #
          ensureDependencies =
            { modules, destination ? "targetNodeModules", visited ? [ ] }:
            if builtins.length modules == 0 then
              ""
            else ''
              Promise.all([
              ${
                lib.concatMapStringsSep ''
                  ,
                '' (module:
                  let
                    hasNoHost = builtins.typeOf (module.host or null) != "set";
                    stub = module.id == module.host or null;
                    seen = builtins.elem { inherit (module) id host; } visited;
                  in (if hasNoHost then ''
                    Promise.all([
                      lib.linkModule('${module}/lib', ${destination}),
                      lib.linkBinaries('${module}/lib', path.join(${destination}, '.bin'))
                    ])
                  '' else if stub then ''
                    lib.linkModule(path.join(process.env.out, 'lib'), ${destination})
                  '' else if seen then ''
                    Promise.resolve()
                  '' else ''
                    hosted['${ makeJSVarName module.id }'] || (hosted['${ makeJSVarName module.id }'] = (async () => {
                      const nodeModules = path.join(
                        process.env.out, 
                        'pkgs',
                        lib.flatVersionedName('${module.moduleName}', '${module.version}'),
                        'node_modules',
                      );
                      const pkg = path.join(nodeModules, '${module.moduleName}');
                      // Copy the package source
                      await lib.copyDir('${module}/lib', pkg);
                      await lib.linkBinaries(pkg, path.join(${destination}, '.bin'));
                      await lib.linkModule(pkg, ${destination})

                      // Host / Link modules
                      const ${ makeJSVarName module.id }TargetNodeModules = nodeModules;
                      return ${
                        ensureDependencies {
                          modules = module.modules;
                          destination =
                            "${ makeJSVarName module.id }TargetNodeModules";
                          visited = builtins.concatLists [
                            visited
                            [{ inherit (module) id host; }]
                          ];
                        }
                      }; 
                    })())
                  '')) modules
              }])
            '';

          # Generates JS code for the current module installation.
          #
          generateInstallScript = ''
            const { promises: fs } = require('fs');
            const path = require('path');
            const lib = require('${./lib/install.js}');

            // This const is used to prevent attempts to host a module if it's already being hosted.
            // This case is possible when several hosted dependencies depend on another single
            // dependency hosted within the same parent. For example, d@1.0.1 npm package.
            const hosted = {};

            async function main() {
              console.error('Executing Node.js install script for ' + process.env.moduleName + ' ...');
              const nodeModules = path.join(
                process.env.out, 
                'pkgs',
                lib.flatVersionedName(process.env.moduleName, process.env.moduleVersion),
                'node_modules',
              );
              const pkg = path.join(nodeModules, process.env.moduleName);
              await lib.copyDir('.', pkg);
              await lib.linkBinaries(pkg, path.join(process.env.out, 'bin'));
              await fs.symlink(pkg, path.join(process.env.out, 'lib'));
              const ${makeJSVarName id}TargetNodeModules = nodeModules;
              return ${
                ensureDependencies {
                  inherit modules;
                  destination = "${makeJSVarName id}TargetNodeModules";
                }
              };
            }

            main().catch(e => {
              process.stderr.write(e.toString());
              process.exit(1);
            });
          '';
        in
        ''
          runHook preInstall

          # It's a relatively complicated beast with recursive calls and
          # intensive code reuse so it's much easier to generate such a script
          # correctly for Node.js rather than for bash.
          moduleName="${moduleName}" \
            moduleVersion=${version} \
            node <<EOF
          ${generateInstallScript}
          EOF

          runHook postInstall
        '';

      postInstall = ''
        # Handle life-cycle scripts
        pushd "$out/lib" >/dev/null
        ${lib.concatMapStringsSep "\n" (script: ''
          script="$(node -e 'process.stdout.write(((require("./package.json") || {}).scripts || {}).${script} || "")')"

          if [[ "${script}" == "install" ]] && [[ -z "$script" ]] && [[ -f ./binding.gyp ]]; then
            script="node-gyp rebuild"
          fi

          if [[ -n "$script" ]]; then
            echo "${moduleName}: invoke \"${script}\" life-cycle script:"
            echo
            echo "( cd \"$out/lib\" && env \"HOME=$TMPDIR\" \"PATH=$out/pkgs/${ref}/node_modules/.bin:$PATH\" bash -c \"$(echo $script | sed 's/"/\\"/g')\" )"
            echo
            env "HOME=$TMPDIR" "PATH=$out/pkgs/${ref}/node_modules/.bin:$PATH" bash -c "$script"
          fi
        '') lifeCycleScripts}

        popd >/dev/null
      '';
  
      phases = [
        "unpackPhase"
        "patchPhase"
        "installPhase"
        "fixupPhase"
        "checkPhase"
      ];

      doCheck = !hasHost && doCheck;
      checkPhase = ''
        has_main="$(node -e 'process.stdout.write(String(!!require(process.env.out + "/lib/package.json").main))')"
        if [[ $has_main == "true" ]] || [[ -f $out/lib/index.js ]]; then
          echo "Checking import of the ${moduleName} ..."
          node -e 'require(process.env.out + "/lib")' || (
            echo
            echo Unable to execute:
            echo "node -e 'require(\"$out/lib\")"
            echo "Import check for the \"${moduleName}\" failed. Consider disable a check for this module in an overlay or fix the error."
            echo
            exit 1
          )
        fi
      '';

    }) // removeAttrs args [ "id" "host" "modules" "passthru" "doCheck" ]));

  # Load generated Nix expression, injects dependencies and returns an extensible attribute set.
  # Same as `makeNixExpression`, is there any use to calling this directly instead of using `load`?
  #
  loadNixExpression = createLoadNixExpression (createBuildNodeModule [ node-gyp ]);
  createLoadNixExpression = fn: m: { overlays ? [ ] }:
    let
      exprs = (lib.makeExtensible (self: {
        buildNodeModule = fn;
        # make it overridable for `curlOpts`
        fetchurl = lib.makeOverridable fetchurl;
      })).extend (import m);
    in
    builtins.foldl' (acc: curr: acc.extend curr) exprs overlays;

  # Creates a derivation that contains a Nix expression for the given yarn.lock file.
  #
  makeNixExpression = lock:
    runCommand "yarn.lock.nix" { nativeBuildInputs = [ bin ]; } ''
      js2nix --lock ${lock} --out $out
    '';

  # Creates a Nix expression for the given yarn.lock file, then applies the given list of 
  # overlays to it.
  #
  load = lockfile: args: loadNixExpression (makeNixExpression lockfile) args;

  # Takes a package.json file and a dependency tree to pick up declared in the package.json file 
  # top-level depedencies and then create a derivation that represents node_modules folder. The rest
  # of the arguments will be passed through to the linkNodeModules function.
  #
  makeNodeModules = package:
    { tree
    , sections ? [ "dependencies" "devDependencies" ]
    , ...
    }@args:
    let modules = selectModules package { inherit tree sections; };
    in linkNodeModules ({
      modules = modules;
    } // (builtins.removeAttrs args [ "tree" "sections" ]));

  # Selects modules from the tree that are defined in given sections of the package.json file and 
  # returns them as a list.
  #
  selectModules = package:
    { tree, sections }:
    let
      parsed = lib.importJSON package;
      deps = builtins.foldl' (acc: curr: if lib.hasAttr curr parsed then (acc // parsed.${curr}) else acc) { } sections;
      withVersions = builtins.attrValues
        (builtins.mapAttrs (name: version: "${name}@${version}") deps);
    in
    builtins.map (n: tree.${n}) withVersions;

  # The js2nix package derivation that provides a binary `js2nix` that can be used to generate
  # a Nix expression, based on given `package.json` & `yarn.lock` files.
  #
  bin = import ./js2nix.nix rec {
    inherit yarn nix parseModuleID selectModules;
    # avoid re-building js2nix with operational node-gyp, because it doesn't depend on it anyway
    buildNodeModule = createBuildNodeModule [
      (stub-node-gyp "Unable to build js2nix dependency with node-gyp. It should not depend on any native code in the first place.")
    ];
    loadNixExpression = createLoadNixExpression buildNodeModule;
  };

  # A helper function that returns an attribute set that contains the npmrc file content.
  #
  fromNPMRC = f:
    let
      c = builtins.readFile f;
      s = lib.splitString "\n" c;
      nc = builtins.filter
        (s: let f = (builtins.substring 0 1 s); in f != "#" && f != "")
        s;
    in
    builtins.foldl'
      (acc: curr:
        let s = lib.splitString "=" curr;
        in acc // {
          "${builtins.head s}" = builtins.concatStringsSep "=" (builtins.tail s);
        })
      { }
      nc;

  # Parses an id from the given package name. For example:
  #
  #   parseModuleID "@canva/js2nix" # -> { scope = "canva"; name = "js2nix"; }
  #   parseModuleID "react" # -> { scope = ""; name = "react"; }
  #
  # A private function for internal use.
  #
  parseModuleID = name:
    with builtins;
    with lib;
    let ss = splitString "/" name;
    in if (length ss) != 1 then {
      scope = substring 1 ((stringLength (head ss)) - 1) (head ss);
      name = head (tail ss);
    } else {
      scope = "";
      inherit name;
    };

  # Returns an overlay that can be applied to a dependency tree to
  # make overrides that are declared in the `package.json` file.
  # Example:
  #  
  #   let
  #     pkgsOverlay = js2nix.makeOverlay ./package.json;
  #     tree = js2nix.load ./yarn.lock {
  #       overlays = [
  #         pkgsOverlay
  #         (self: super: {
  #           # ...
  #         })
  #       ];
  #     };
  #   in tree;
  # 
  # This function is intended to replace the need for overriding in Nix
  # expressions and give non-Nixers a more comfortable way to make their
  # dependency trees amended with crucial missing pieces of information.
  #
  makeOverlay = callPackage ./overlay.nix { };

  # Returns an attr set with all the potentially usefull resources, related to the
  # `package.json` and `yarn.lock` files' tuple. The main API.
  #
  buildEnv =
    { package-json
    , yarn-lock ? null
    , yarn-lock-nix ? (makeNixExpression yarn-lock)
    , overlays ? [ ]
    }@args:
    assert lib.hasAttr "yarn-lock" args -> ! lib.hasAttr "yarn-lock-nix" args;
    assert lib.hasAttr "yarn-lock-nix" args -> ! lib.hasAttr "yarn-lock" args;

    let
      pkgs = loadNixExpression yarn-lock-nix {
        overlays = [ (makeOverlay package-json) ] ++ overlays;
      };
      nodeModules = (makeNodeModules package-json {
        tree = pkgs;
        exposeBin = true;
      }) // {
        prod = makeNodeModules package-json
          {
            tree = pkgs;
            sections = [ "dependencies" ];
          };
      };
    in
    {
      inherit nodeModules pkgs;
    };
in
{
  # Main API
  __functor = self: buildEnv;
  inherit buildEnv;

  inherit
    # Exported executables
    bin
    proxy
    node-gyp

    # Granular API exposure
    load
    loadNixExpression
    makeNodeModules
    makeOverlay
    selectModules

    # Helpers
    fromNPMRC;
}
