{ lib
, rustPlatform
, fetchFromGitHub
, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "mozlz4";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "jusw85";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-faoFvDvqCr0EPsqlQvHZpd74b5pzYhtkJ6gXebwEm/w=";
  };

  cargoSha256 = "sha256-/R4UQky0gAwh465HjlePoxUTcYWbgS5n+sJ+kkWzDw0=";

  passthru.updateScript = nix-update-script {
    attrPath = pname;
  };

  meta = with lib; {
    description = "Decompress / compress mozlz4 files";
    homepage = "https://github.com/jusw85/mozlz4";
    license = licenses.mit;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
