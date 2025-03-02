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

  useFetchCargoVendor = true;
  cargoHash = "sha256-QYS6TzICnNB0/ESLMVf4F9Bi+SN8oRKkTm+FwOHKtVw=";

  buildInputs = [ sqlite ];
}
