{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkGotifyPlugin,
  # keep-sorted end
}:
mkGotifyPlugin {
  pname = "authentik";
  version = "2.9.1-unstable-2026-06-09";

  src = fetchFromGitHub {
    owner = "ckocyigit";
    repo = "gotify-authentik-plugin";
    rev = "v2.9.1-2";
    hash = "sha256-DvZ3/4SizpZAgy7IwPnOEtYRIuDpd1e1hgobAhc7r2I=";
  };

  patchedSourceHash = "sha256-K9k3yWidXotRi/Buo9bdDfA7QwdHLeFv2oEqqCAdqs8=";
  vendorHash = "sha256-wvFr3/Aqvz2TmdfNb213lOhEeZ4RUN5vy5Dfda+f4ZM=";

  meta = {
    # keep-sorted start
    description = "Gotify plugin that enables receiving and processing webhooks from Authentik";
    homepage = "https://github.com/ckocyigit/gotify-authentik-plugin";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
