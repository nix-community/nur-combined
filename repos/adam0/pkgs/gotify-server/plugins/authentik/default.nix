{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkGotifyPlugin,
  # keep-sorted end
}:
mkGotifyPlugin rec {
  pname = "authentik";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "ckocyigit";
    repo = "gotify-authentik-plugin";
    rev = "v${version}";
    hash = "sha256-Y7x/PSLobsYecLVtSBcrbzhyxHCrTgekwKbvCi3/MTo=";
  };

  dependencyHash = "sha256-K9k3yWidXotRi/Buo9bdDfA7QwdHLeFv2oEqqCAdqs8=";
  vendorHash = "sha256-wvFr3/Aqvz2TmdfNb213lOhEeZ4RUN5vy5Dfda+f4ZM=";

  meta = {
    # keep-sorted start
    description = "Gotify plugin that enables receiving and processing webhooks from Authentik";
    homepage = "https://github.com/ckocyigit/gotify-authentik-plugin";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
