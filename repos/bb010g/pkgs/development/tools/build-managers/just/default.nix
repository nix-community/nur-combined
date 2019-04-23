{ stdenv, rustPlatform, fetchFromGitHub
, bash, coreutils, dash
}:

let
  inherit (stdenv.lib) escapeShellArg;
in

rustPlatform.buildRustPackage rec {
  pname = "just";
  version = "0.3.13";

  src = fetchFromGitHub {
    owner = "casey";
    repo = "just";
    rev = "v${version}";
    sha256 = "1n1448vrigz6jc73b3abq53lpwcggdwq93cjxqb2hn87qcqlyii7";
  };

  cargoSha256 = "0awfq9fhcin2q6mvv54xw6i6pxhdp9xa1cpx3jmpf3a6h8l6s9wp";

  outputs = [ "bin" "doc" "out" ];

  postPatch = ''
    for f in \
        src/justfile.rs tests/{integration,interrupts}.rs
    do substituteInPlace "$f" \
        --replace '/bin/echo' ${escapeShellArg coreutils.out}'/bin/echo' \
        --replace '/bin/sh' ${escapeShellArg bash.out}'/bin/sh' \
        --replace '/usr/bin/env cat' \
          ${escapeShellArg coreutils.out}'/bin/cat' \
        --replace '/usr/bin/env sh' ${escapeShellArg bash.out}'/bin/sh'
    done
    substituteInPlace tests/integration.rs \
        --replace "env_var('USER')" "env_var('JUST_TEST_VAR')" \
        --replace 'env::var("USER")' 'env::var("JUST_TEST_VAR")'
  '';

  postInstall = ''
    # fix buildRustPackage installPhase locations
    moveToOutput bin "''${!outputBin}"
    moveToOutput lib "''${!outputLib}"

    mkdir -p $out/share/doc/just
    cp -t $out/share/doc/just GRAMMAR.md README.adoc
  '';

  checkInputs = [ bash coreutils dash ];

  preCheck = ''
    export JUST_TEST_VAR=foo
  '';

  meta = with stdenv.lib; {
    description = "Just a command runner";
    longDescription = ''
      just is a handy way to save and run project-specific commands.

      Commands are stored in a file called justfile or Justfile with syntax
      inspired by make. You can then run them with just COMMAND.

      just produces detailed error messages and avoids make's idiosyncrasies,
      so debugging a justfile is easier and less surprising than debugging a
      makefile.
    '';
    homepage = https://github.com/casey/just;
    license = with licenses; cc0;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.all;
  };
}

