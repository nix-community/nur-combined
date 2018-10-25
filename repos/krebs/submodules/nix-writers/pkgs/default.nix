with import ../lib;

pkgs: oldpkgs: {
  execve = name: { filename, argv ? null, envp ? {}, destination ? "" }:
    pkgs.writeC name { inherit destination; } /* c */ ''
      #include <unistd.h>

      static char *const filename = ${toC filename};

      ${if argv == null
        then /* Propagate arguments */ /* c */ ''
          #define MAIN_ARGS int argc, char **argv
        ''
        else /* Provide fixed arguments */ /* c */ ''
          #define MAIN_ARGS void
          static char *const argv[] = ${toC (argv ++ [null])};
        ''}

      static char *const envp[] = ${toC (
        mapAttrsToList (k: v: "${k}=${v}") envp ++ [null]
      )};

      int main (MAIN_ARGS) {
        execve(filename, argv, envp);
        return -1;
      }
    '';

  execveBin = name: cfg:
    pkgs.execve name (cfg // { destination = "/bin/${name}"; });

  makeScriptWriter = { interpreter, check ? null }: name: text:
    assert (with types; either absolute-pathname filename).check name;
    pkgs.write (baseNameOf name) {
      ${optionalString (types.absolute-pathname.check name) name} = {
        inherit check;
        executable = true;
        text = "#! ${interpreter}\n${text}";
      };
    };

  write = name: specs0:
  let
    env = filevars // { passAsFile = attrNames filevars; };

    files = map write' specs;

    filevars = genAttrs' (filter (hasAttr "var") files)
                         (spec: nameValuePair spec.var spec.val);

    specs =
      mapAttrsToList
        (path: spec: let
          known-types = [ "link" "text" ];
          found-types = attrNames (getAttrs known-types spec);
          type = assert length found-types == 1; head found-types;
        in spec // { inherit path type; })
        specs0;

    writers.link =
      { path
      , link
      }:
      assert path == "" || types.absolute-pathname.check path;
      assert types.package.check link;
      {
        install = /* sh */ ''
          ${optionalString (path != "") /* sh */ ''
            ${pkgs.coreutils}/bin/mkdir -p $out${dirOf path}
          ''}
          ${pkgs.coreutils}/bin/ln -s ${link} $out${path}
        '';
      };

    writers.text =
      { path
      , check ? null
      , executable ? false
      , mode ? if executable then "0755" else "0644"
      , text
      }:
      assert path == "" || types.absolute-pathname.check path;
      assert types.bool.check executable;
      assert types.file-mode.check mode;
      rec {
        var = "file_${hashString "sha1" path}";
        val = text;
        install = /* sh */ ''
          ${optionalString (check != null) /* sh */ ''
            ${check} ''$${var}Path
          ''}
          ${pkgs.coreutils}/bin/install \
              -m ${mode} \
              -D \
              ''$${var}Path $out${path}
        '';
      };

    write' = spec: writers.${spec.type} (removeAttrs spec ["type"]);
  in
    # Use a subshell because <nixpkgs/stdenv/generic/setup.sh>'s genericBuild
    # sources (or evaluates) the buildCommand and we don't want to modify its
    # shell.  In particular, exitHandler breaks in multiple ways with set -u.
    pkgs.runCommand name env /* sh */ ''
      (
        set -efu
        ${concatMapStringsSep "\n" (getAttr "install") files}
      )
    '';

  writeBash = name: text:
    assert (with types; either absolute-pathname filename).check name;
    pkgs.write (baseNameOf name) {
      ${optionalString (types.absolute-pathname.check name) name} = {
        executable = true;
        text = "#! ${pkgs.bash}/bin/bash\n${text}";
      };
    };

  writeBashBin = name:
    assert types.filename.check name;
    pkgs.writeBash "/bin/${name}";

  writeC = name: {
    destination ? "",
    libraries ? {}
  }: text: pkgs.runCommand name {
    inherit text;
    buildInputs = [ pkgs.pkgconfig ] ++ attrValues libraries;
    passAsFile = [ "text" ];
  } /* sh */ ''
    PATH=${makeBinPath [
      pkgs.binutils-unwrapped
      pkgs.coreutils
      pkgs.gcc
      pkgs.pkgconfig
    ]}
    exe=$out${destination}
    mkdir -p "$(dirname "$exe")"
    gcc \
        ${optionalString (libraries != [])
          /* sh */ "$(pkg-config --cflags --libs ${
            concatMapStringsSep " " escapeShellArg (attrNames libraries)
          })"
        } \
        -O \
        -o "$exe" \
        -Wall \
        -x c \
        "$textPath"
    strip --strip-unneeded "$exe"
  '';

  writeDash = pkgs.makeScriptWriter {
    interpreter = "${pkgs.dash}/bin/dash";
  };

  writeDashBin = name:
    assert types.filename.check name;
    pkgs.writeDash "/bin/${name}";

  writeEximConfig = name: text: pkgs.runCommand name {
    inherit text;
    passAsFile = [ "text" ];
  } /* sh */ ''
    # TODO validate exim config even with config.nix.useChroot == true
    # currently doing so will fail because "user exim was not found"
    #${pkgs.exim}/bin/exim -C "$textPath" -bV >/dev/null
    mv "$textPath" $out
  '';

  writeHaskell = name: extra-depends: text:
    pkgs.stdenv.mkDerivation {
      inherit name;
      src = pkgs.writeHaskellPackage name {
        executables.${name} = {
          inherit extra-depends;
          text = text;
        };
      };
      phases = [ "buildPhase" ];
      buildPhase = ''
        ln -fns $src/bin/${name} $out
      '';
    };

  writeHaskellPackage =
    k:
    let
      k' = parseDrvName k;
      name = k'.name;
      version = if k'.version != "" then k'.version else "0";
    in
    { base-depends ? ["base"]
    , executables ? {}
    , ghc-options ? ["-Wall" "-O3" "-threaded" "-rtsopts"]
    , haskellPackages ? pkgs.haskellPackages
    , library ? null
    , license ? "WTFPL"
    }:
    let
      isExecutable = executables != {};
      isLibrary = library != null;

      cabal-file = pkgs.writeText "${name}-${version}.cabal" /* cabal */ ''
        build-type: Simple
        cabal-version: >= 1.2
        name: ${name}
        version: ${version}
        ${concatStringsSep "\n" (mapAttrsToList exe-section executables)}
        ${optionalString isLibrary (lib-section library)}
      '';

      exe-install =
        exe-name:
        { file ? pkgs.writeText "${name}-${exe-name}.hs" text
        , relpath ? "${exe-name}.hs"
        , text
        , ... }:
        if types.filename.check exe-name
          then /* sh */ "install -D ${file} $out/${relpath}"
          else throw "argument ‘exe-name’ is not a ${types.filename.name}";

      exe-section =
        exe-name:
        { build-depends ? base-depends ++ extra-depends
        , extra-depends ? []
        , file ? pkgs.writeText "${name}-${exe-name}.hs" text
        , relpath ? "${exe-name}.hs"
        , text
        , ... }: /* cabal */ ''
          executable ${exe-name}
            build-depends: ${concatStringsSep "," build-depends}
            ghc-options: ${toString ghc-options}
            main-is: ${relpath}
        '';

      get-depends =
        { build-depends ? base-depends ++ extra-depends
        , extra-depends ? []
        , ...
        }:
        build-depends;

      lib-install =
        { exposed-modules
        , ... }:
        concatStringsSep "\n" (mapAttrsToList mod-install exposed-modules);

      lib-section =
        { build-depends ? base-depends ++ extra-depends
        , extra-depends ? []
        , exposed-modules
        , ... }: /* cabal */ ''
          library
            build-depends: ${concatStringsSep "," build-depends}
            ghc-options: ${toString ghc-options}
            exposed-modules: ${concatStringsSep "," (attrNames exposed-modules)}
        '';

      mod-install =
        mod-name:
        { file ? pkgs.writeText "${name}-${mod-name}.hs" text
        , relpath ? "${replaceStrings ["."] ["/"] mod-name}.hs"
        , text
        , ... }:
        if types.haskell.modid.check mod-name
          then /* sh */ "install -D ${file} $out/${relpath}"
          else throw "argument ‘mod-name’ is not a ${types.haskell.modid.name}";
    in
      haskellPackages.mkDerivation {
        inherit isExecutable isLibrary license version;
        executableHaskellDepends =
          attrVals
            (concatMap get-depends (attrValues executables))
            haskellPackages;
        libraryHaskellDepends =
          attrVals
            (optionals isLibrary (get-depends library))
            haskellPackages;
        pname = name;
        src = pkgs.runCommand "${name}-${version}-src" {} /* sh */ ''
          install -D ${cabal-file} $out/${cabal-file.name}
          ${optionalString isLibrary (lib-install library)}
          ${concatStringsSep "\n" (mapAttrsToList exe-install executables)}
        '';
      };

  writeJq = name: text:
    assert (with types; either absolute-pathname filename).check name;
    pkgs.write (baseNameOf name) {
      ${optionalString (types.absolute-pathname.check name) name} = {
        check = pkgs.writeDash "jqcheck.sh" ''
          exec ${pkgs.jq}/bin/jq -f "$1" < /dev/null
        '';
        inherit text;
      };
    };

  writeJS = name: { deps ? [] }: text:
  let
    node-env = pkgs.buildEnv {
      name = "node";
      paths = deps;
      pathsToLink = [
        "/lib/node_modules"
      ];
    };
  in pkgs.writeDash name ''
    export NODE_PATH=${node-env}/lib/node_modules
    exec ${pkgs.nodejs}/bin/node ${pkgs.writeText "js" text}
  '';

  writeJSBin = name:
    pkgs.writeJS "/bin/${name}";

  writeJSON = name: value: pkgs.runCommand name {
    json = toJSON value;
    passAsFile = [ "json" ];
  } /* sh */ ''
    ${pkgs.jq}/bin/jq . "$jsonPath" > "$out"
  '';

  writeNixFromCabal =
    trace (toString [
      "The function `writeNixFromCabal` has been deprecated in favour of"
      "`writeHaskell`."
    ])
    (name: path: pkgs.runCommand name {} /* sh */ ''
      ${pkgs.cabal2nix}/bin/cabal2nix ${path} > $out
    '');

  writePerl = name: { deps ? [] }:
  let
    perl-env = pkgs.buildEnv {
      name = "perl-environment";
      paths = deps;
      pathsToLink = [
        "/lib/perl5/site_perl"
      ];
    };
  in
  pkgs.makeScriptWriter {
    interpreter = "${pkgs.perl}/bin/perl -I ${perl-env}/lib/perl5/site_perl";
  } name;

  writePerlBin = name:
    pkgs.writePerl "/bin/${name}";

  writePython2 = name: { deps ? [], flakeIgnore ? [] }:
  let
    py = pkgs.python2.withPackages (ps: deps);
    ignoreAttribute = optionalString (flakeIgnore != []) "--ignore ${concatMapStringsSep "," escapeShellArg flakeIgnore}";
  in
  pkgs.makeScriptWriter {
    interpreter = "${py}/bin/python";
    check = pkgs.writeDash "python2check.sh" ''
      exec ${pkgs.python2Packages.flake8}/bin/flake8 --show-source ${ignoreAttribute} "$1"
    '';
  } name;

  writePython2Bin = name:
    pkgs.writePython2 "/bin/${name}";

  writePython3 = name: { deps ? [], flakeIgnore ? [] }:
  let
    py = pkgs.python3.withPackages (ps: deps);
    ignoreAttribute = optionalString (flakeIgnore != []) "--ignore ${concatMapStringsSep "," escapeShellArg flakeIgnore}";
  in
  pkgs.makeScriptWriter {
    interpreter = "${py}/bin/python";
    check = pkgs.writeDash "python3check.sh" ''
      exec ${pkgs.python3Packages.flake8}/bin/flake8 --show-source ${ignoreAttribute} "$1"
    '';
  } name;

  writePython3Bin = name:
    pkgs.writePython3 "/bin/${name}";

  writeSed = pkgs.makeScriptWriter {
    interpreter = "${pkgs.gnused}/bin/sed -f";
  };
}
