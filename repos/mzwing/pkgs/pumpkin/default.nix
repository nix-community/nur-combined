{
  lib,
  rustPlatform,
  source,
  rustfmt,
}:
rustPlatform.buildRustPackage rec {
  inherit (source) pname src;
  version = "0-unstable-${source.date}";

  cargoHash = "sha256-U+hfeNqNn2+Z8BB4Ohm9h3BluGL4jHIbJUTObG+hClk=";

  nativeBuildInputs = [rustfmt];

  cargoBuildFlags = ["--workspace"];

  doCheck = true;
  cargoTestFlags = ["--workspace"];

  postInstall = ''
    install -Dm644 LICENSE README.md -t $out/share/doc/pumpkin
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x $out/bin/pumpkin
    test -f $out/share/doc/pumpkin/LICENSE
    test -f $out/share/doc/pumpkin/README.md

    runHook postInstallCheck
  '';

  meta = {
    description = "Empowering everyone to host fast and efficient Minecraft servers";
    homepage = "https://github.com/Pumpkin-MC/Pumpkin";
    license = lib.licenses.gpl3Only;
    mainProgram = "pumpkin";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
