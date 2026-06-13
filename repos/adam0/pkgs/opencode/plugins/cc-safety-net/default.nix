{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "cc-safety-net";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "kenryu42";
    repo = "claude-code-safety-net";
    rev = "v${version}";
    hash = "sha256-PpRJpxrQoupDIOaw7ASc39aXPDg4rAimBVB2TP+kNR4=";
  };

  dependencyHash = null;

  meta = {
    # keep-sorted start
    description = "A coding agent hook that acts as a safety net";
    homepage = "https://github.com/kenryu42/claude-code-safety-net";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
