{
  lib,
  stdenv,
  fetchFromGitLab,
  symlinkJoin,

  akku,
  chez,

  akkuPackages,
}:
let
  deps = symlinkJoin {
    name = "loko-deps";
    paths = builtins.attrValues {
      inherit (akkuPackages)
        machine-code
        struct-pack
        laesare
        pfds
        ;
    };
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "loko";
  version = "0.12.2";

  src = fetchFromGitLab {
    owner = "weinholt";
    repo = "loko";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ykGYdxtJIF4ZLSD3jJv9yoIzsNrqh5S46lFnIoAP1BU=";
  };

  postPatch = ''
    rm Akku.lock

    substituteInPlace Akku.manifest \
      --replace-fail '(depends ("laesare" "^1.0.0") ("pfds" "^0.3.0") ("machine-code" "^2.2.0"))' "(depends)"
    substituteInPlace scheme-wrapper \
      --replace-fail 'which ' 'command -v '
  '';

  nativeBuildInputs = [
    akku
    chez
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  preBuild = ''
    akku install
    for lib in "machine-code" "struct" "laesare" "pfds"; do
      ln -s ${deps}/lib/scheme-libs/$lib .akku/lib/$lib
    done
  '';

  postInstall = ''
    for lib in "machine-code" "struct" "laesare" "pfds"; do
      ln -s ${deps}/lib/scheme-libs/$lib $out/lib/loko
    done
  '';

  dontStrip = true;

  meta = {
    description = "Optimizing Scheme compiler for Linux, NetBSD and bare hardware.";
    homepage = "https://scheme.fail";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "loko";
    platforms = lib.platforms.all;
  };
})
