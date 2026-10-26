{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "supaline.yazi";
  version = "0-unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "yohkuri";
    repo = pname;
    rev = "867df699f46ce12c66ee53585cda3d97ee8c0aea";
    hash = "sha256-nrdppocG+4GV8NEf5+aUFRrjbf+vJe9gPZ4yt7loRG4=";
  };

  meta = {
    # keep-sorted start
    description = "Configurable linemode columns for Yazi";
    homepage = "https://github.com/yohkuri/supaline.yazi";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
