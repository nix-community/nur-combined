{
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  lib,
}:

buildGoModule rec {
  name = "legionlinuxtui";

  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "nooneknowspeter";
    repo = "legionlinuxtui";
    rev = "v${version}";
    hash = "sha256-Uyw9xp3EUerbJQ52nc5Anwccp46BO1e2q2M+6YYVMus=";
  };

  vendorHash = null;

  buildPhase = ''
    go build -o build/
  '';

  installPhase = ''install -Dm755 build/legionlinuxtui $out'';

  doCheck = false;

  meta = with lib; {
    description = "Control lenovo legion laptops in the terminal";
    homepage = "https://github.com/nooneknowspeter/legionlinuxtui/";
    changelog = "https://github.com/nooneknowspeter/legionlinuxtui/blob/main/CHANGELOG.md";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "legionlinuxtui";
  };
}
