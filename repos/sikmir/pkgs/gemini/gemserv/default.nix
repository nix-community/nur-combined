{
  lib,
  stdenv,
  rustPlatform,
  fetchFromSourcehut,
  pkg-config,
  openssl,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "gemserv";
  version = "0.6.6";

  src = fetchFromSourcehut {
    owner = "~int80h";
    repo = "gemserv";
    rev = "v${version}";
    hash = "sha256-jFh7OksYGXGWwLb4HtAuDQ7OsWxedqeLARPI20RyAgQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ehN8cHkY7FWMWZ9E+ETMEsPdUuupJlEGN6+76ocFI8k=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  postInstall = ''
    install -Dm644 config.toml -t $out/share/gemserv
  '';

  meta = {
    description = "A gemini server written in rust";
    homepage = "https://git.sr.ht/~int80h/gemserv";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
