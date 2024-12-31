{
  lib,
  buildNpmPackage,
  habitica,
  jq,
  settings ? { },
}:

let
  # Filter client-specific settings to avoid unnecessary rebuilds when
  # changing server-specific settings
  #
  # https://github.com/HabitRPG/habitica/blob/v5.31.1/website/client/vue.config.js#L17-L36
  allClientSettings = {
    AMAZON_PAYMENTS_SELLER_ID = true;
    AMAZON_PAYMENTS_CLIENT_ID = true;
    AMAZON_PAYMENTS_MODE = true;
    EMAILS_COMMUNITY_MANAGER_EMAIL = true;
    EMAILS_TECH_ASSISTANCE_EMAIL = true;
    EMAILS_PRESS_ENQUIRY_EMAIL = true;
    BASE_URL = true;
    GA_ID = true;
    STRIPE_PUB_KEY = true;
    GOOGLE_CLIENT_ID = true;
    APPLE_AUTH_CLIENT_ID = true;
    AMPLITUDE_KEY = true;
    LOGGLY_CLIENT_TOKEN = true;
    TRUSTED_DOMAINS = true;
    TIME_TRAVEL_ENABLED = true;
    DEBUG_ENABLED = true;
    CONTENT_SWITCHOVER_TIME_OFFSET = true;
  };

  clientSettings = lib.filterAttrs (name: _: allClientSettings.${name} or false) settings;
in
buildNpmPackage {
  pname = "habitica-client";
  version = habitica.version;

  src = habitica.src;
  sourceRoot = "${habitica.src.name}/website/client";

  patchFlags = [ "-p3" ];
  patches = [
    # The client package implicitly depends on moment-recur defined in
    # the parent habitica package, but it's dependencies aren't
    # fetched in this derivation
    ./add-implied-client-dependencies.patch
  ];

  npmDepsHash = "sha256-yrklEY961tWNyDf/XgFNt/jxgiFyDJFQ6vdXjSv95Bc=";

  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];

  strictDeps = true;
  nativeBuildInputs = [ jq ];
  preConfigure = ''
    export NODE_PATH="$PWD/node_modules"
    (
      cd ../..
      chmod +w .
      echo ${lib.escapeShellArg (builtins.toJSON clientSettings)} \
        | jq -s '.[0] * .[1]' config.json.example - > config.json
    )
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist "$out"
    runHook postInstall
  '';

  passthru = {
    inherit settings;
  };

  meta = habitica.meta // {
    description = "Static frontend assets for Habitica";
    homepage = "https://github.com/HabitRPG/habitica/tree/develop/website/client";
  };
}
