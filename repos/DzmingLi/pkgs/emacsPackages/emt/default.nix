{
  lib,
  emacsPackages,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
}:

let
  version = "0.10.2";
  libExt = stdenv.hostPlatform.extensions.sharedLibrary;

  src = fetchFromGitHub {
    owner = "LuciusChen";
    repo = "emt";
    tag = "v${version}";
    hash = "sha256-Be7pCQMfBO4u+hK80a+VDtSrBw/DhVOLJB4WhJNp4Dg=";
  };

  emt-module = rustPlatform.buildRustPackage {
    pname = "emt-module";
    inherit version src;

    sourceRoot = "${src.name}/module";
    cargoHash = "sha256-R80YoFwYjHCe0EUl2gkPD0kJCkhcSZnYpn1TyfSQseI=";

    nativeBuildInputs = [ rustPlatform.bindgenHook ];

    postInstall = ''
      mkdir -p "$out/lib/modules"
      mv \
        "$out/lib/libemt_module${libExt}" \
        "$out/lib/modules/libemt_module${libExt}"
    '';

    meta = {
      description = "Jieba-rs dynamic module for EMT";
      homepage = "https://github.com/LuciusChen/emt";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.unix;
    };
  };
in
emacsPackages.trivialBuild {
  pname = "emt";
  inherit version src;

  postPatch = ''
    substituteInPlace emt.el \
      --replace-fail 'user-emacs-directory' '"${emt-module}/lib"'
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    mkdir -p module/target/release
    ln -s \
      "${emt-module}/lib/modules/libemt_module${libExt}" \
      "module/target/release/libemt_module${libExt}"
    emacs --batch -Q -L . \
      -l test/emt-test.el \
      -f ert-run-tests-batch-and-exit
    runHook postCheck
  '';

  passthru = { inherit emt-module; };

  meta = {
    description = "Han word boundaries for Emacs backed by jieba-rs";
    homepage = "https://github.com/LuciusChen/emt";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
}
