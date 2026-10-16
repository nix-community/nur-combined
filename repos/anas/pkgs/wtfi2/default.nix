{ lib
, fetchFromGitHub
, rustPlatform
}:
let
  pname = "wtfi2";
  version = "0.7.0";
  owner = "kanywst";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-vkshSHAOKwKs1CVCyiXI4VbQ8Q6DYmmGPaqE9PU7ofo=";
  };

  cargoHash = "sha256-7uXeKkJZpj8GdMQfl9nePmW59wjti9YytaUoaeKjN0s=";

  # There is no tests
  doCheck = false;

  meta = {
    description = "What The F*ck Internet — a live, visual network path diagnostic that pinpoints exactly where your connection dies.";
    homepage = "https://github.com/kanywst/wtfi2";
    changelog = "https://github.com/kanywst/wtfi2/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "wtfi";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
