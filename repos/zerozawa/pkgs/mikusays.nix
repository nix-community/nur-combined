{
  fetchFromGitHub,
  rustPlatform,
  lib,
  ...
}:
rustPlatform.buildRustPackage (finalAttrs: rec {
  pname = "mikusays";
  version = "0.1.5";
  src = fetchFromGitHub {
    owner = "xxanqw";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-JZVsTlLIcbK0vKIBrwRnCR5AELoaYZkb7azdiYiR77s=";
  };

  cargoHash = "sha256-+K9R21X5/D7AsDKeSA1rLBPsSzZmKWyrny30G2SffHc=";
  # 2 NO_COLOR integration tests fail in the build sandbox (exit status assertion)
  doCheck = false;

  meta = with lib; {
    description = "A `cowsay` clone with Hatsune Miku ASCII art and speech bubbles.";
    homepage = "https://github.com/xxanqw/mikusays";
    platforms = with platforms; (windows ++ linux ++ darwin);
    license = with licenses; [ mit ];
    mainProgram = pname;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
})
