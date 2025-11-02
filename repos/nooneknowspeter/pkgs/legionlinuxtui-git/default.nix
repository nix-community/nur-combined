{
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  lib,
}:

buildGoModule rec {
  name = "legionlinuxtui";

  version = "main";

  src = fetchFromGitHub {
    owner = "nooneknowspeter";
    repo = "legionlinuxtui";
    rev = "${version}";
    hash = "sha256-W8CLgQv5B8b/wcy9bPjeRFegO3zIBMqbGQFOnx0Fd8g=";
  };

  vendorHash = null;

  buildPhase = ''
    go build -o build/
  '';

  installPhase = ''install -Dm755 build/legionlinuxtui $out/bin/legionlinuxtui'';

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
