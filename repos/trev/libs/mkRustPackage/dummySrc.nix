# Builds a copy of a cargo workspace that contains only its manifests, lockfile,
# cargo config and empty stubs for every target. Everything is read at eval
# time and written with `builtins.toFile`, so the result only changes when those
# files change, not when any other source file does.
#
# The versions of local crates are set to 0.0.0 in both the manifests and the
# lockfile, so bumping the version doesn't change the result either. The
# normalized lockfile is available as `lockFileContents`.
{
  lib,
  runCommandLocal,
}:

{
  src,
  # name of the directory the source is unpacked to
  name,
  # path of the workspace root relative to `src`
  cargoDir ? "",
  # contents of the workspace's Cargo.lock
  lockFileContents,
}:

let
  srcPath = rel: "${src}${lib.optionalString (rel != "") "/${rel}"}";

  joinPath =
    a: b:
    if a == "" then
      b
    else if b == "" then
      a
    else
      "${a}/${b}";

  # resolves `.` and `..` segments, returning null if the path leaves `src`
  normalize =
    path:
    let
      segments = lib.filter (s: s != "" && s != ".") (lib.splitString "/" path);
      resolved = lib.foldl' (
        acc: segment:
        if acc == null then
          null
        else if segment == ".." then
          if acc == [ ] then null else lib.init acc
        else
          acc ++ [ segment ]
      ) [ ] segments;
    in
    if resolved == null then null else lib.concatStringsSep "/" resolved;

  exists = rel: builtins.pathExists (srcPath rel);
  isDir = rel: exists rel && builtins.readFileType (srcPath rel) == "directory";
  listDir = rel: if isDir rel then builtins.readDir (srcPath rel) else { };
  readFile = rel: builtins.unsafeDiscardStringContext (builtins.readFile (srcPath rel));

  isCrate = rel: rel != null && exists (joinPath rel "Cargo.toml");
  manifest = rel: fromTOML (readFile (joinPath rel "Cargo.toml"));

  # expands `*` and `?` in workspace member globs
  expandGlob =
    pattern:
    let
      toRegex = lib.replaceStrings [ "\\*" "\\?" ] [ "[^/]*" "[^/]" ];
      expandSegment =
        bases: segment:
        if lib.hasInfix "*" segment || lib.hasInfix "?" segment then
          lib.concatMap (
            base:
            lib.mapAttrsToList (entry: _: joinPath base entry) (
              lib.filterAttrs (
                entry: type: type == "directory" && builtins.match (toRegex (lib.escapeRegex segment)) entry != null
              ) (listDir base)
            )
          ) bases
        else
          map (base: joinPath base segment) bases;
    in
    lib.foldl' expandSegment [ "" ] (lib.splitString "/" pattern);

  depKeys = [
    "dependencies"
    "dev-dependencies"
    "dev_dependencies"
    "build-dependencies"
    "build_dependencies"
  ];

  # crates that replace registry crates, their versions have to stay intact
  patchedCrates =
    rel: toml:
    map (dep: normalize (joinPath rel dep.path)) (
      lib.filter (dep: lib.isAttrs dep && dep ? path) (
        lib.concatMap lib.attrValues (lib.attrValues (toml.patch or { }))
        ++ lib.attrValues (toml.replace or { })
      )
    );

  # crates referenced by a manifest: workspace members and path dependencies
  referencedCrates =
    rel: toml:
    let
      depTables = table: lib.concatMap (key: lib.attrValues (table.${key} or { })) depKeys;

      deps =
        depTables toml
        ++ lib.concatMap depTables (lib.attrValues (toml.target or { }))
        ++ lib.attrValues (toml.workspace.dependencies or { })
        ++ lib.concatMap lib.attrValues (lib.attrValues (toml.patch or { }))
        ++ lib.attrValues (toml.replace or { });

      pathDeps = map (dep: normalize (joinPath rel dep.path)) (
        lib.filter (dep: lib.isAttrs dep && dep ? path) deps
      );

      excluded = map (path: normalize (joinPath rel path)) (toml.workspace.exclude or [ ]);
      members = lib.subtractLists excluded (
        lib.concatMap (
          glob:
          let
            pattern = normalize (joinPath rel glob);
          in
          lib.optionals (pattern != null) (expandGlob pattern)
        ) (toml.workspace.members or [ ])
      );
    in
    lib.filter isCrate (members ++ pathDeps);

  crates = map (item: item.key) (
    builtins.genericClosure {
      startSet = [ { key = normalize cargoDir; } ];
      operator = item: map (key: { inherit key; }) (referencedCrates item.key (manifest item.key));
    }
  );

  patched = lib.concatMap (rel: patchedCrates rel (manifest rel)) crates;

  # names and versions of the crates whose version is set to 0.0.0
  normalizedPackages =
    let
      names = lib.concatMap (
        rel: lib.optional (!lib.elem rel patched && manifest rel ? package.name) (manifest rel).package.name
      ) crates;
    in
    lib.filter (pkg: !(pkg ? source) && lib.elem pkg.name names) (
      (fromTOML lockFileContents).package or [ ]
    );

  # edits the lockfile as text to keep its formatting, so cargo doesn't rewrite it
  normalizedLock =
    let
      separator = "\n[[package]]\n";
      normalizeBlock =
        block:
        if lib.hasInfix "\nsource = " block then
          block
        else
          builtins.replaceStrings
            (map (pkg: "name = \"${pkg.name}\"\nversion = \"${pkg.version}\"\n") normalizedPackages)
            (map (pkg: "name = \"${pkg.name}\"\nversion = \"0.0.0\"\n") normalizedPackages)
            block;
    in
    builtins.replaceStrings (map (pkg: "\"${pkg.name} ${pkg.version}\"") normalizedPackages)
      (map (pkg: "\"${pkg.name} 0.0.0\"") normalizedPackages)
      (lib.concatStringsSep separator (map normalizeBlock (lib.splitString separator lockFileContents)));

  normalizeManifest =
    rel: toml:
    let
      # path dependencies don't need a version, and it might not match anymore
      normalizeDeps =
        table:
        table
        // lib.genAttrs (lib.filter (key: table ? ${key}) depKeys) (
          key:
          lib.mapAttrs (
            _: dep: if lib.isAttrs dep && dep ? path then removeAttrs dep [ "version" ] else dep
          ) table.${key}
        );

      normalizeVersion =
        table: table // lib.optionalAttrs (lib.isString (table.version or null)) { version = "0.0.0"; };
    in
    normalizeDeps toml
    // lib.optionalAttrs (toml ? target) { target = lib.mapAttrs (_: normalizeDeps) toml.target; }
    // lib.optionalAttrs (toml ? package && !lib.elem rel patched) {
      package = normalizeVersion toml.package;
    }
    // lib.optionalAttrs (toml ? workspace) {
      workspace =
        toml.workspace
        // lib.optionalAttrs (toml.workspace ? package) {
          package = normalizeVersion toml.workspace.package;
        }
        // lib.optionalAttrs (toml.workspace ? dependencies) {
          inherit (normalizeDeps { inherit (toml.workspace) dependencies; }) dependencies;
        };
    };

  # serializes everything as inline tables, which is valid if not pretty
  toTOML =
    let
      toValue =
        value:
        if lib.isAttrs value then
          "{ ${lib.concatStringsSep ", " (lib.mapAttrsToList toKeyValue value)} }"
        else if lib.isList value then
          "[${lib.concatMapStringsSep ", " toValue value}]"
        else
          builtins.toJSON value;
      toKeyValue = key: value: "${builtins.toJSON key} = ${toValue value}";
    in
    value: lib.concatMapStrings (line: "${line}\n") (lib.mapAttrsToList toKeyValue value);

  # target source files cargo would discover or was told about
  crateFiles =
    rel:
    let
      toml = manifest rel;

      existing = lib.filter (path: exists (joinPath rel path));

      discover =
        dir:
        lib.concatLists (
          lib.mapAttrsToList (
            entry: type:
            if type != "directory" && lib.hasSuffix ".rs" entry then
              [ "${dir}/${entry}" ]
            else if type == "directory" then
              existing [ "${dir}/${entry}/main.rs" ]
            else
              [ ]
          ) (listDir (joinPath rel dir))
        );

      explicit =
        lib.concatMap
          (kind: lib.concatMap (target: lib.optional (target ? path) target.path) (toml.${kind} or [ ]))
          [
            "bin"
            "example"
            "test"
            "bench"
          ];

      build = toml.package.build or true;

      libs = lib.optional (toml.lib.path or null != null) toml.lib.path ++ existing [ "src/lib.rs" ];

      mains =
        explicit
        ++ existing [ "src/main.rs" ]
        ++ lib.concatMap discover [
          "src/bin"
          "examples"
          "tests"
          "benches"
        ]
        ++ (
          if lib.isString build then
            [ build ]
          else if build then
            existing [ "build.rs" ]
          else
            [ ]
        );

      stubs = content: paths: lib.genAttrs (map (path: joinPath rel (normalize path)) paths) (_: content);
    in
    {
      ${joinPath rel "Cargo.toml"} = toTOML (normalizeManifest rel toml);
    }
    // stubs "fn main() {}\n" mains
    // stubs "" libs;

  # cargo config and lockfile, which affect how dependencies are built
  extraFiles =
    lib.genAttrs (lib.filter exists (
      lib.unique (
        lib.concatMap
          (dir: [
            (joinPath dir ".cargo/config.toml")
            (joinPath dir ".cargo/config")
          ])
          [
            ""
            cargoDir
          ]
      )
    )) readFile
    // {
      ${joinPath cargoDir "Cargo.lock"} = normalizedLock;
    };

  files = lib.foldl' (acc: rel: acc // crateFiles rel) extraFiles crates;
in

assert lib.assertMsg (isCrate (normalize cargoDir))
  "mkRustPackage: no Cargo.toml found at '${cargoDir}' in ${srcPath ""}, the source must be a directory";

runCommandLocal name
  {
    passthru.lockFileContents = normalizedLock;
  }
  ''
    mkdir -p "$out"
    ${lib.concatStrings (
      lib.mapAttrsToList (path: content: ''
        install -Dm644 ${builtins.toFile "dummy" content} "$out/${path}"
      '') files
    )}
  ''
