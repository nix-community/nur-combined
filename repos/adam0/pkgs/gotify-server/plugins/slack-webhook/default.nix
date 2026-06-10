{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkGotifyPlugin,
  # keep-sorted end
}:
mkGotifyPlugin {
  pname = "slack-webhook";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "NilsGriebner";
    repo = "gotify-slack-webhook";
    rev = "0.0.2";
    hash = "sha256-Pehj9WFTcAdFf/RqULdTmYEMhKjYRmos9/5n8/cb1Cw=";
  };

  patchedSourceHash = "sha256-mof+JC04lGT5gxA1JmvlQ+CZ2wAArdoPUlCHtv5bz10=";
  vendorHash = "sha256-Pop8R92hfEFZnht7Fd0i990EZwclex8yxu0H5h384Io=";

  meta = {
    # keep-sorted start
    description = "Gotify plugin that sends push messages to Slack via webhooks";
    homepage = "https://github.com/NilsGriebner/gotify-slack-webhook";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
