{
  lib,
  stdenv,
  fetchFromGitLab,

  akku,
  chez,

  akkuPackages,
}:

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
    mkdir -p .akku/lib
    ln -s ${akkuPackages.machine-code}/lib/scheme-libs/machine-code .akku/lib/machine-code
    ln -s ${akkuPackages.struct-pack}/lib/scheme-libs/struct .akku/lib/struct
    ln -s ${akkuPackages.laesare}/lib/scheme-libs/laesare .akku/lib/laesare
    ln -s ${akkuPackages.pfds}/lib/scheme-libs/pfds .akku/lib/pfds
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
