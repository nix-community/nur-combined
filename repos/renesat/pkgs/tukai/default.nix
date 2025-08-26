{
  fetchFromGitHub,
  rustPlatform,
  lib,
}:
rustPlatform.buildRustPackage rec {
  pname = "tukai";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "hlsxx";
    repo = "tukai";
    tag = "v${version}";
    hash = "sha256-YJtna4NIk9mmwymepFSZB8viUSPDU4XouRE5GCujSmk=";
  };

  cargoHash = "sha256-1V1DrewPGDJWmOoYdtK1HS/t83zFac/tgatfDTKxAmA=";

  postPatch = ''
    substituteInPlace src/storage/storage_handler.rs \
      --replace-fail "tests/{}.tukai" "/tmp/tests/{}.tukai"
  '';

  meta = {
    description = "The app provides an interactive typing experience with switchable templates, designed to help users improve their typing speed and accuracy";
    homepage = "https://github.com/hlsxx/tukai";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [renesat];
  };
}
