{ lib
, cacert
, nixosTests
, rustPlatform
, fetchFromGitHub
, nix-update-script
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage {
  pname = "redlib";
  version = "0-unstable-2025-12-04";
  src = fetchFromGitHub {
    owner = "chowder";
    repo = "redlib";
    rev = "42fe41bc4c64690aa91cd1cfecec3bad3438354f";
    hash = "sha256-iYH5WeQLitDA6unTJoR0+DYQWmTSQd0WRFfwRYvkVHI=";
  };

  cargoHash = "sha256-/oSZR/VMYyDTA9b48EXll/FC7UwN0xhA9BtQVwrBoMk=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  postInstall = ''
    install --mode=444 -D contrib/redlib.service $out/lib/systemd/system/redlib.service
    substituteInPlace $out/lib/systemd/system/redlib.service \
      --replace-fail "/usr/bin/redlib" "$out/bin/redlib"
  '';

  checkFlags = [
    # All these test try to connect to Reddit.
    # utils.rs
    "--skip=test_fetching_subreddit_quarantined"
    "--skip=test_fetching_nsfw_subreddit"
    "--skip=test_fetching_ws"

    # client.rs
    "--skip=test_obfuscated_share_link"
    "--skip=test_share_link_strip_json"
    "--skip=test_localization_popular"
    "--skip=test_private_sub"
    "--skip=test_banned_sub"
    "--skip=test_gated_sub"
    "--skip=test_default_subscriptions"
    "--skip=test_rate_limit_check"

    # subreddit.rs
    "--skip=test_fetching_subreddit"
    "--skip=test_gated_and_quarantined"

    # user.rs
    "--skip=test_fetching_user"

    # These try to connect to the oauth client
    # oauth.rs
    "--skip=test_oauth_client"
    "--skip=test_oauth_client_refresh"
    "--skip=test_oauth_token_exists"
    "--skip=test_oauth_headers_len"
    "--skip=oauth::test_generic_web_backend"
    "--skip=oauth::test_mobile_spoof_backend"
  ];

  env = {
    #SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    OPENSSL_NO_VENDOR = true;
  };

  passthru = {
    tests = nixosTests.redlib;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "Private front-end for Reddit (Continued fork of Libreddit) fork that works";
    homepage = "https://github.com/chowder/redlib";
    license = lib.licenses.agpl3Only;
    mainProgram = "redlib";
    maintainers = with lib.maintainers; [
      szanko
    ];
  };
}
