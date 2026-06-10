{
  # keep-sorted start
  fetchgit,
  lib,
  mkGotifyPlugin,
  # keep-sorted end
}:
mkGotifyPlugin {
  pname = "webhooks";
  version = "1.1.3";

  src = fetchgit {
    url = "https://git.leon.wtf/leon/gotify-webhooks-plugin.git";
    rev = "0d7d4b25";
    hash = "sha256-UTCgCBBBioKkq1XDP4Uqeu5sd8hbU5RQAgluGNBppqk=";
  };

  patchedSourceHash = "sha256-aKU7TwjuPZP2SzM4021xQwU3FYVKGTuCZfp9+Z7NKXs=";
  vendorHash = "sha256-wvFr3/Aqvz2TmdfNb213lOhEeZ4RUN5vy5Dfda+f4ZM=";

  meta = {
    # keep-sorted start
    description = "Gotify plugin that enables receiving and processing generic webhooks";
    homepage = "https://git.leon.wtf/leon/gotify-webhooks-plugin";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
