{
  fetchFromGitHub,
  firebird,
  freetds,
  installShellFiles,
  lib,
  libx11,
  mariadb-connector-c,
  ncurses,
  nix-update-script,
  postgresql,
  stdenv,
  sqlite,
  unixODBC,
  versionCheckHook,
  withSqlite ? true,
  withMysql ? false,
  withPostgresql ? false,
  withOdbc ? false,
  withFirebird ? false,
  withTds ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "seed7";
  version = "5.4.10";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ThomasMertes";
    repo = "seed7";
    tag = "Seed7_release_2025-09-30";
    hash = "sha256-e7FMG/OVejuF7gxoycKW15A/u3m67b/MJoF5/j/Q2pk=";
  };

  buildInputs =
    [libx11 ncurses]
    ++ lib.optionals withSqlite [sqlite]
    ++ lib.optionals withMysql [mariadb-connector-c]
    ++ lib.optionals withPostgresql [postgresql]
    ++ lib.optionals withOdbc [unixODBC]
    ++ lib.optionals withFirebird [firebird]
    ++ lib.optionals withTds [freetds];

  nativeBuildInputs = [installShellFiles];

  dontConfigure = true;

  makeFlags = ["-C" "src"];

  buildFlags = [
    "CC:=$(CC)"
    "S7_LIB_DIR:=$(out)/lib/seed7/bin"
    "SEED7_LIBRARY:=$(out)/lib/seed7/lib"
    "all"
  ];

  makefile = let
    platform = stdenv.hostPlatform;
  in
    if platform.isDarwin
    then "mk_osx.mak"
    else if platform.isOpenBSD
    then "mk_freebsd.mk"
    else if platform.isCygwin
    then "mk_cygw.mak"
    else if platform.isWindows
    then "mk_mingw.mak"
    else "makefile";

  # Explicitly specified because the auto-detection in checkPhase does not account for -C
  checkTarget = "test";

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  installPhase = ''
    runHook preInstall

    installBin bin/s7{,c}
    install -Dm 644 -t $out/lib/seed7/bin bin/*.a
    install -Dm 644 -t $out/lib/seed7/lib lib/*.s7i
    install -Dm 644 -t $out/lib/seed7/lib/comp lib/comp/*.s7i
    installManPage doc/s7{,c}.1

    runHook postInstall
  '';

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;
  versionCheckProgramArg = "-h";

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "The extensible programming language";
    longDescription = ''
      Seed7 is an extensible general purpose programming language designed by Thomas
      Mertes. It is a higher level language compared to Ada, C/C++ and Java.
      In Seed7 new statements and operators can be declared easily. Functions with
      type results and type parameters are more elegant than a template or generics
      concept. Object orientation is used where it brings advantages and not in
      places where other solutions are more obvious. Although Seed7 contains several
      concepts from other programming languages, it is generally not considered a
      direct descendant of any other programming language.

      Major features include:

      - user defined statements and operators,
      - abstract data types,
      - templates without special syntax,
      - OO with interfaces and multiple dispatch,
      - statically typed,
      - interpreted or compiled,
      - portable,
      - runs under Linux/Unix/Windows.
    '';
    homepage = "https://seed7.net/";
    changelog = "https://github.com/ThomasMertes/seed7/blob/${finalAttrs.src.rev}/doc/chlog.txt";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.all;
    mainProgram = "s7";
  };
})
