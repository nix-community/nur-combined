{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "supaline.yazi";
  version = "0-unstable-2026-11-06";

  src = fetchFromGitHub {
    owner = "yohkuri";
    repo = pname;
    rev = "2437adfb60f17d41b08c7ca4288e5f3f845033ac";
    hash = "sha256-e45He3CI5Yt3w7IH9AaNMHveRco0mksSGwcf/89NObU=";
  };

  meta = {
    # keep-sorted start
    description = "Configurable linemode columns for Yazi";
    homepage = "https://github.com/yohkuri/supaline.yazi";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
