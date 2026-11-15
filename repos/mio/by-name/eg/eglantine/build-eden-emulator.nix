# SPDX-FileCopyrightText: Copyright 2026 Eglantine Community

# SPDX-FileCopyrightText: Copyright 2026 Eglantine Emulator Project
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-License-Identifier: GPL-3.0-or-later

# see an example of how to use this function in package.nix
{
  lib,
  pkgs,
  # CMakeLists.txt calls AddJsonPackage for some entries only on some
  # platforms, and those decisions are CMake code rather than manifest data,
  # so a reader has to be told what this platform never downloads:
  #   vulkan-validation-layers  inside `if (ANDROID AND YUZU_DOWNLOAD_ANDROID_VVL)`
  #   llvm-mingw                the clang-cl (Windows) branch
  #   linkernsbypass            never AddJsonPackage'd in CMakeLists.txt
  # (conditions, not line numbers: the numbers drifted twice in four days)
  #
  # moltenvk is the one entry that differs between the platforms we build:
  # externals/CMakeLists.txt reaches AddJsonPackage(moltenvk) inside
  # `if (APPLE)`, so Linux never downloads it and darwin does. On darwin it is
  # therefore left in the fetch set, which is more robust than relying on
  # find_library(MOLTENVK_LIBRARY ...) finding a system copy: if that lookup
  # fails, CPM falls through to AddJsonPackage and tries to download, and the
  # build sandbox has no network.
  skipDeps ? [
    "vulkan-validation-layers"
    "llvm-mingw"
    "linkernsbypass"
  ]
  ++ lib.optional (!pkgs.stdenv.hostPlatform.isDarwin) "moltenvk",
}:

let
  manifestOf = src: builtins.fromJSON (builtins.readFile ./cpmfile.json);

  isOn = v: v == true || v == "true";

  # `ci: true` entries are prebuilt CI-only artifacts and carry no hash, so
  # they cannot be pinned from here. `bundled: true` entries still get fetched:
  # CPMUTIL_FORCE_BUNDLED is off by default on Linux, so CPMUtil reaches for the
  # network for those too, and upstream's own Linux job downloads them. Fetching
  # them from the manifest keeps the bytes identical.
  fetchable =
    manifest: lib.filterAttrs (name: entry: !(isOn (entry.ci or false)) && entry ? hash) manifest;

  # CPMUtil's get_package_url: a release artifact when `artifact` is set, else
  # the GitHub source tarball for the pinned revision.
  urlOf =
    entry:
    let
      host = entry.git_host or "github.com";
      base = "https://${host}/${entry.repo}";
      substitute =
        s:
        lib.replaceStrings
          [ "%NUMERIC_VERSION%" "%VERSION%" ]
          [
            (entry.numeric_version or entry.version)
            entry.version
          ]
          s;
    in
    if entry ? artifact then
      "${base}/releases/download/${entry.version}/${substitute entry.artifact}"
    else
      "${base}/archive/${entry.version}.tar.gz";

  # The manifest stores base16 sha512; Nix wants a hash it can verify. Ask for
  # SRI where the builtin exists and fall back to the raw base16 digest with an
  # explicit algorithm, both of which Nix accepts for a fixed-output path.
  hashOf =
    hash:
    if builtins ? convertHash then
      builtins.convertHash {
        inherit hash;
        hashAlgo = "sha512";
        toHashFormat = "sri";
      }
    else
      hash;

  # filter out stuff that no build step needs
  # this keeps the hash stable if someone e.g. just edits the README
  sourceOf =
    src:
    if builtins.typeOf src != "path" then
      src
    else
      lib.cleanSourceWith {
        inherit src;
        # stripHash turns this into the build directory's name
        # ($NIX_BUILD_TOP/source), and ccache's keys are computed over paths
        # inside that directory -- CCACHE_BASEDIR alone does not remove the
        # component. Naming it exactly what the unfiltered tree was named keeps
        # the build directory, and therefore every ccache key, unchanged.
        name = "source";
        filter =
          path: _type:
          let
            base = builtins.baseNameOf path;
            top = lib.head (lib.splitString "/" (lib.removePrefix "${toString src}/" (toString path)));
          in
          !(builtins.elem top [
            ".ci"
            ".claude"
            ".forgejo"
            ".github"
            ".tx"
            "docs"
            "hooks"
            "nix"
          ])
          && !(lib.hasSuffix ".md" base)
          && !(builtins.elem base [
            ".mcp.json"
            "relower_words.cpp"
            ".clang-format"
            ".clang-tidy"
            ".editorconfig"
            ".gitattributes"
            ".gitignore"
            ".shellcheckrc"
            "Doxyfile"
            "flake.lock"
            "flake.nix"
            "shell.nix"
          ]);
      };

  # The patch files are a small, self-contained tree. Giving them their own
  # store path means a patched dependency's derivation only changes when the
  # patches change, instead of on every edit anywhere in the repository - which
  # is what referencing the whole source tree does.
  patchRootOf =
    src:
    if builtins.typeOf src == "path" then
      if builtins.pathExists "${src}/.patch" then
        builtins.path {
          name = "eglantine-cpm-patches";
          path = "${src}/.patch";
        }
      else
        null
    else
      pkgs.runCommandLocal "eglantine-cpm-patches" { } ''
        if [ -d ${src}/.patch ]; then
          cp -r ${src}/.patch/. $out
        else
          mkdir -p $out
        fi
      '';

  mkDep =
    patchRoot: name: entry:
    let
      tarball = pkgs.fetchurl {
        url = urlOf entry;
        hash = hashOf entry.hash;
      };
    in
    pkgs.stdenvNoCC.mkDerivation {
      pname = "${name}-source";
      version =
        if builtins.match "[0-9a-f]{7,40}" entry.version != null then
          "0-unstable-2026-11-15"
        else
          entry.version;
      src = tarball;

      nativeBuildInputs = with pkgs; [
        patch
        zstd
        unzip
      ];

      patches = lib.optionals (entry ? patches) (map (p: "${patchRoot}/${name}/${p}") entry.patches);

      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp -a . "$out"/
        runHook postInstall
      '';
    };

  cpmDeps =
    src:
    let
      patchRoot = patchRootOf src;
    in
    lib.mapAttrs (name: entry: mkDep patchRoot name entry) (
      lib.removeAttrs (fetchable (manifestOf src)) skipDeps
    );

  customDirFlags =
    src: deps:
    lib.mapAttrsToList (
      name: path: "-D${(manifestOf src).${name}.package or name}_CUSTOM_DIR=${path}"
    ) deps;
in
{
  inherit cpmDeps customDirFlags;

  # Everything the caller has to supply beyond a source tree is the system
  # dependencies and the configure flags the repository's CI uses.
  #
  # The dependency lists are the caller's, not nixpkgs' `eden`'s. They used to
  # default to that package's inputs, which made this derivation's dependency
  # set another emulator's decision -- and made it impossible to submit the
  # package to nixpkgs, where you cannot inherit from a sibling derivation.
  # `nix/package.nix` passes Eglantine's own list.
  buildEdenEmulator =
    {
      src,
      version,
      pname ? "eglantine",
      # builder is replaced for PGO builds,
      # which means different stdenv
      stdenv ? pkgs.stdenv,
      nativeBuildInputs ? [ ],
      buildInputs ? [ ],
      extraNativeBuildInputs ? [ ],
      extraBuildInputs ? [ ],
      cmakeFlags ? [ ],
      # deps that the caller does not want or cannot fetch
      # from the CPM manifest
      deps ? cpmDeps src,
      doCheck ? false,
      ccache ? false,
      # environment for the build. Merged with the ccache variables when ccache
      # is on, so a caller can set its own without dropping them
      env ? { },
      meta ? { },
      ...
    }@args:
    stdenv.mkDerivation (
      {
        # Without this, stdenv word-splits every cmakeFlags entry on spaces, so
        # a value like "-DCMAKE_CXX_FLAGS=… -Wno-unused-but-set-variable"
        # reaches CMake as several separate arguments and CMake interprets the
        # compiler flag as one of its own warning switches. nixpkgs' eden sets
        # this, which is why these same flags work there.
        __structuredAttrs = true;

        inherit
          pname
          version
          doCheck
          meta
          ;

        # filtered, see sourceOf above
        src = sourceOf src;

        nativeBuildInputs = nativeBuildInputs ++ extraNativeBuildInputs ++ lib.optional ccache pkgs.ccache;
        buildInputs = buildInputs ++ extraBuildInputs;

        # Nix bind-mounts a path into a build only when sandbox-paths names it,
        # and the build users have to be able to write it:
        #   extra-sandbox-paths = /nix/var/cache/ccache        (nix.conf)
        #   mkdir -m 0777 -p /nix/var/cache/ccache             (or 0770 root:nixbld)
        # This is the path NixOS's own CCache instructions use, so a machine
        # that follows them needs no extra setup.
        #
        # The same path and the same flags everywhere mean a ccache-enabled
        # build is still one derivation rather than a CI-only variant. If CI
        # were the only place ccache was on, the binary cache would fill with a
        # result that nobody's plain `nix build` evaluates to, and users would
        # rebuild from scratch anyway.
        env =
          env
          // lib.optionalAttrs ccache {
            CCACHE_DIR = "/nix/var/cache/ccache";
            CCACHE_MAXSIZE = "3G";
            CCACHE_COMPRESS = "true";
            # Nix deviation: Nix rebuilds the source tree
            # on every run, so mtimes differ between two builds of
            # byte-identical contents
            CCACHE_COMPILERCHECK = "content";
            # writable by all nixbldX users
            CCACHE_UMASK = "000";
            # pch_defines and time_macros are both required before ccache will
            # cache anything compiled through a precompiled header -- without them
            # it answers "could_not_use_precompiled_header" and runs the real
            # compiler. The tree builds SDL3 with a PCH, so this is the
            # "Uncacheable calls: 1" every run has been reporting.
            CCACHE_SLOPPINESS = "include_file_ctime,include_file_mtime,time_macros,file_stat_matches,pch_defines";
          };

        # ccache is made to be optional
        preConfigure = ''
          if mkdir -p "$CCACHE_DIR" 2>/dev/null && [ -w "$CCACHE_DIR" ]; then
            # Paths inside the preprocessed source have to be stable for a hit
            # to be possible, and the build root differs by platform.
            export CCACHE_BASEDIR="''${NIX_BUILD_TOP:-/build}"
          else
            export CCACHE_DISABLE=1
          fi
        ''
        + (args.preConfigure or "");

        # see CPM manifest resolution above
        cmakeFlags = [
          "-DCPMUTIL_FORCE_SYSTEM=OFF"
        ]
        ++ customDirFlags src deps
        ++ cmakeFlags
        ++ lib.optional ccache "-DUSE_CCACHE=ON";
      }
      // lib.removeAttrs args [
        "src"
        "version"
        "pname"
        "stdenv"
        "nativeBuildInputs"
        "buildInputs"
        "extraNativeBuildInputs"
        "extraBuildInputs"
        "cmakeFlags"
        "deps"
        "doCheck"
        "ccache"
        "env"
        "preConfigure"
        "meta"
      ]
    );
}
