# this package was copied from:
# <https://forge.leaf.ninja/nettika/oils-for-unix-from-source>
#
# notes:
# - python2 deps might be more easily provided by doing `fetchWedge` with a fixed output?
#   <https://github.com/oils-for-unix/oils/issues/1923#issuecomment-2043047035>
# - TODO: install manpage
# - TODO: ensure cross compilation
{
  lib,
  stdenv,
  fetchFromGitHub,
  symlinkJoin,
  callPackage,
  # Build tools
  python2, # Legacy build scripts. Marked insecure but not in final binary
  python3,
  # Newest version that supports mypy 0.780's typeshed. TODO: python3.10 is dropped from nixpkgs
  python310 ? lib.warnOnInstantiate "python != 3.10 unlikely to work for oils" python3,
  re2c,
  ninja,
  git,
  cmark,
  which,
  time,
  readline,
}:

let
  mypy-extensions = callPackage ./mypy-extensions-0.4.4.nix { python3 = python310; };
  typed-ast = callPackage ./typed-ast-1.5.5.nix { python3 = python310; };
  mypy-for-mycpp = callPackage ./mypy-0.780.nix {
    python3 = python310;
    inherit mypy-extensions typed-ast;
  };

  python = python310.withPackages (ps: [
    mypy-for-mycpp
    ps.typing-extensions
  ]);

  # Configure script expects readline lib and headers at the same prefix
  readline-all = symlinkJoin {
    name = "readline-all";
    paths = [
      readline
      readline.dev
    ];
  };

  # python2 is used only at build time:
  # `disallowedReferences` is used to ensure the final package doesn't propagate it.
  # for another example of this pattern, see <repo:nixos/nixpkgs:pkgs/development/misc/resholve/default.nix>
  python2' = python2.overrideAttrs (old: {
    meta = old.meta // {
      knownVulnerabilities = [];
    };
  });

in
stdenv.mkDerivation (finalAttrs: {
  pname = "oils-for-unix";
  version = "0.37.0";

  src = fetchFromGitHub {
    owner = "oils-for-unix";
    repo = "oils";
    # Reference by release branch
    rev = "release/${finalAttrs.version}";
    hash = "sha256-d2i2P8ZiGb+FYzZIzs0pY2gIRQGGuenLbxrGhafVxVc=";
  };

  nativeBuildInputs = [
    python2'
    python
    re2c
    ninja
    git
    cmark
    which
    time
  ];

  buildInputs = [ readline ];

  postPatch = ''
    patchShebangs .

    substituteInPlace build/dynamic-deps.sh \
      --replace-quiet '/usr/bin/env' "$(command -v env)"

    # _PyVerify_fd is Windows-only
    substituteInPlace pyext/posixmodule.c \
      --replace-quiet '_PyVerify_fd(fd)' '1'

    substituteInPlace doctools/cmark.py \
      --replace-quiet "raise AssertionError('bin/cmark not found')" \
        "cmark_path = '${cmark}/bin/cmark'"
  '';

  configurePhase = ''
    runHook preConfigure
    ./configure \
      --datarootdir=$out \
      --with-readline \
      --readline=${readline-all}
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    . build/dev-shell.sh
    build/py.sh configure-for-dev
    build/stamp.sh write-git-commit
    build/py.sh py-source
    build/py.sh py-extensions
    build/doc.sh all-ref
    ./NINJA-config.sh
    ninja _bin/cxx-opt/oils-for-unix
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 _bin/cxx-opt/oils-for-unix $out/bin/oils-for-unix
    ln -s oils-for-unix $out/bin/osh
    ln -s oils-for-unix $out/bin/ysh
    runHook postInstall
  '';

  # Suppress warnings from older C code in vendor dependencies
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=incompatible-function-pointer-types";

  disallowedReferences = [
    python2'
    python310
  ];

  meta = {
    broken = true;  # XXX(2026-05-18): python310 is no longer in nixpkgs
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    mainProgram = "osh";
  };

  passthru =
    let
      mkShell =
        shellName:
        symlinkJoin {
          name = "oils-for-unix-${shellName}-${finalAttrs.version}";
          paths = [ finalAttrs.finalPackage ];
          passthru.shellPath = "/bin/${shellName}";
          meta = finalAttrs.meta // {
            mainProgram = shellName;
          };
        };
    in
    {
      osh = mkShell "osh";
      ysh = mkShell "ysh";
    };
})

