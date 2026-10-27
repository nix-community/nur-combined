{ lib
, fetchFromGitHub
, rustPlatform
, bash
,
}:
let
  pname = "flyline";
  version = "1.10.0";
  owner = "HalFrgrd";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-nOCawyqUdOkxaqFS11Tp9IaOm7hevWhnLjpxsr5YWCo=";
  };

  cargoHash = "sha256-4ifX9N1OnIxwNRy4rWBZSqE0460G/dx+N8N4ZHInBpk=";

  buildInputs = [ bash ];

  # There is no tests
  doCheck = false;

  installPhase = ''
    runHook preInstall

    lib=$(find target -type f -name 'libflyline.so' -print -quit)
    install -Dm755 "$lib" "$out/lib/libflyline.so.${version}"
    ln -s "libflyline.so.${version}" "$out/lib/libflyline.so"

    install -Dm644 LICENSE-MIT LICENSE-GPLv3 -t "$out/share/licenses/${pname}"
    install -Dm644 README.md "$out/share/doc/${pname}/README.md"

    runHook postInstall
  '';

  meta = {
    description = "Bash plugin to replace readline for a modern line editing experience: syntax highlighting, agent integration, rich prompts, tooltips, fuzzy history search, and more.";
    homepage = "https://github.com/HalFrgrd/flyline";
    changelog = "https://github.com/HalFrgrd/flyline/releases/tag/v${version}";
    license = with lib.licenses; [
      mit
      gpl3Only
    ];
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
