{ rustPlatform

  # Dependencies
, sqlite
}:

rustPlatform.buildRustPackage rec {
  pname = "email-hash";
  version = "0.3.0";

  src = fetchGit {
    url = ~/akorg/project/current/email-hash/email-hash;
    ref = "v${version}";
  };

  cargoHash = "sha256-yQflzab3O16mGQduGfhJZ/I3oLgJKE9zRzlffS8uLVw=";

  buildInputs = [ sqlite ];
}
