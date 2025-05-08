{ rustPlatform

  # Dependencies
, sqlite
}:

rustPlatform.buildRustPackage (email-hash: {
  pname = "email-hash";
  version = "0.3.0";

  src = fetchGit {
    url = ~/akorg/project/current/email-hash/email-hash;
    ref = "v${email-hash.version}";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-QYS6TzICnNB0/ESLMVf4F9Bi+SN8oRKkTm+FwOHKtVw=";

  buildInputs = [ sqlite ];
})
