{ lib
, fetchFromGitHub
, rustPlatform
,
}:
let
  pname = "swpui";
  version = "0.10.1";
  owner = "beeb";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub rec {
    inherit owner;
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-VbwaZKni5no+ei7fXi14QUJMjL6PHB2ck0n50kQMlaw=";
  };

  cargoHash = "sha256-rrC0TUbFjlWjdUEa+aYtirjXUSuc83bl4uGX6Tkr37M=";

  # There is no tests
  doCheck = false;

  meta = {
    description = "Search and replace, TUI style.";
    homepage = "https://github.com/beeb/swpui";
    changelog = "https://github.com/beeb/swpui/releases/tag/v${version}";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "swp";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = with lib.platforms; unix ++ windows;
  };
}
