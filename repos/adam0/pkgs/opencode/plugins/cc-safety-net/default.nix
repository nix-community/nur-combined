{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "cc-safety-net";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "kenryu42";
    repo = "claude-code-safety-net";
    rev = "v${version}";
    hash = "sha256-EniF9gjEWe6+FaSrC4PyoTN4w9FlyhZ+eU7Bp1X/USY=";
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
