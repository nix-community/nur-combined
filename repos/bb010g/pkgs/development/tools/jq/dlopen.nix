{ stdenv, buildPackages, fetchFromGitHub
, oniguruma
# installCheck inputs
, python3 ? null
# features
, enableValgrindChecks ? true
, less ? null, valgrind ? null, which ? null
}:

assert enableValgrindChecks -> valgrind != null;
assert enableValgrindChecks -> which != null;

let
  inherit (stdenv) lib;

  # from ./docs/Pipfile{,.lock}
  docsPythonPackages = ps: [
    ps.jinja2
    ps.lxml
    ps.markdown
    ps.pyyaml_3 or ps.pyyaml
  ];
  buildDocsPython = buildPackages.python3.withPackages docsPythonPackages;
  docsPython = python3.withPackages docsPythonPackages;
in

stdenv.mkDerivation rec {
  pname = "jq-unstable";
  version = "2019-07-09+dlopen";

  src = fetchFromGitHub {
    owner = "nicowilliams";
    repo = "jq";
    rev = "46b9d612af9e3822c43a70978c1d64b49a42bd07";
    sha256 = "10b022533qs15a8cvx6w64shl0n80mp2v14j29l6kinw7v4d0hgn";
  };

  outputs = [ "bin" "doc" "man" "dev" "lib" "out" ];

  nativeBuildInputs = [
    buildPackages.autoreconfHook
  ];
  buildInputs = [
    oniguruma
  ];
  installCheckInputs = [
    docsPython
  ] ++ lib.optionals enableValgrindChecks [
    valgrind
    which
  ];

  patches = [
    ./nix-docs-python.patch
    ./nix-version.patch
  ];

  postPatch = ''
    for file in configure.ac scripts/version; do
      substituteInPlace "$file" \
        --subst-var version
    done

    substituteInPlace Makefile.am \
      --subst-var-by docs_python ${buildDocsPython}/bin/python
  '';

  configureFlags = [
    "--bindir=\${bin}/bin"
    "--sbindir=\${bin}/bin"
    "--datadir=\${doc}/share"
    "--mandir=\${man}/share/man"
    (lib.enableFeature enableValgrindChecks "valgrind")
  ] ++
    # jq is linked to libjq:
    lib.optional (!stdenv.isDarwin) "LDFLAGS=-Wl,-rpath,\\\${libdir}";

  # jq is broken on dlopen
  doInstallCheck = false;
  installCheckTarget = "check";

  preInstallCheck = ''
    substituteInPlace tests/mantest \
      --replace 'pipenv run python' 'python'
  '';

  postInstallCheck = ''
    $bin/bin/jq --help >/dev/null
  '';

  meta = {
    description = ''A lightweight and flexible command-line JSON processor'';
    downloadPage = https://stedolan.github.io/jq/download/;
    homepage = https://stedolan.github.io/jq/;
    license = lib.licenses.mit;
    maintainers = let m = lib.maintainers; in [ m.raskin m.globin m.bb010g ];
    platforms = let p = lib.platforms; in p.linux ++ p.darwin;
    updateWalker = true;
  };
}
