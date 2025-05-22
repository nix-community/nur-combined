{
  stdenv,
  lib,
  fetchFromGitHub,
  rustc,
  fasm,
  makeWrapper,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "good_training_language";
  version = "0-unstable-2024-04-03";

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "good_training_language";
    rev = "41107324ca5cf45921b4e3816439bf9de9ba9dae";
    hash = "sha256-e6OmONyII30SJU0yVavSpJX93hmX7J3xhZyR8AufrNs=";
  };

  nativeBuildInputs = [
    rustc
    fasm
    makeWrapper
  ];

  buildPhase = "./собрать.sh";
  doCheck = true;
  checkPhase = "./тест.sh";
  installPhase = "mkdir -p $out/bin; cp ./сборка/хуяк $out/bin";
  fixupPhase = "wrapProgram $out/bin/хуяк --prefix PATH : ${lib.makeBinPath [ fasm ]}";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Хороший Учебный Язык";
    homepage = "https://github.com/tsoding/good_training_language";
    license = lib.licenses.mit; # It's translated to Russian as well but AFAICT this is just MIT
    mainProgram = "хуяк";
  };
}
