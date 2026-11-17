# Alertmanager 0.35.0 with prometheus/alertmanager#5651 (telegram_configs
# update_message), which edits one Telegram message per alert group instead of
# sending a new one. The patch is vendored from the PR head b6a9f4df04 and
# applies to v0.35.0 only. Drop this file once a release ships the option and
# nixpkgs carries it.
#
# 0.35.0 serves the Elm UI from app/dist/elm and the experimental Mantine UI
# from app/dist/mantine (mounted at /ui/). The Elm UI is rebuilt from the new
# source; elm.json is unchanged since 0.33.1, so nixpkgs' pinned Elm package
# set still applies, and only the npm lockfile hash differs. The Mantine UI is
# deliberately not built: in 0.35.0 its alert and silence pages are still
# placeholders and only the status page works, so it is not worth a second npm
# build. /ui/ answers 404 while / keeps the usual interface.
{
  lib,
  prometheus-alertmanager,
  fetchFromGitHub,
  fetchNpmDeps,
}:
let
  version = "0.35.0";
  src = fetchFromGitHub {
    owner = "prometheus";
    repo = "alertmanager";
    tag = "v${version}";
    hash = "sha256-5LvztWE9NyidvondMWQtDG1N2HpGHV3Urz9kNrUk7B0=";
  };
  elmUi = prometheus-alertmanager.elmUi.overrideAttrs (old: {
    inherit version src;
    npmDeps = fetchNpmDeps {
      name = "alertmanager-elm-ui-${version}-npm-deps";
      inherit src;
      sourceRoot = "${src.name}/ui/app";
      inherit (old) postPatch;
      hash = "sha256-lQaBuiw0IHTLHwqOAwiC4LeNGrzAQFWScMzedKoGQbE=";
    };
  });
in
prometheus-alertmanager.overrideAttrs (
  finalAttrs: old: {
    inherit version src;
    vendorHash = "sha256-0pqugpISejz+OGSFShD/pGQQGloGvbiVUaW8Pv/rqpk=";
    patches = (old.patches or [ ]) ++ [ ./patches/alertmanager-telegram-update-message.patch ];
    postPatch = ''
      mkdir -p ui/app/dist
      cp -r ${elmUi}/. ui/app/dist
    '';
    # The default check phase only covers cmd/; also run the patched notifier tests.
    postCheck = (old.postCheck or "") + ''
      go test ./notify/telegram/...
    '';
    passthru = old.passthru // {
      inherit elmUi;
    };
  }
)
