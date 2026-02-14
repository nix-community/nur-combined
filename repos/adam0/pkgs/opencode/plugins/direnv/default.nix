{
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "direnv";
  version = "2025.1211.9";

  src = fetchFromGitHub {
    owner = "simonwjackson";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-5fmyNIQjF5v8TYWRsGMtaWCj9KxoQimX5/XTUcl65kU=";
  };

  dependencyHash = "sha256-qZDt9E8Kkb2AGFzy3OPkYczIbXWmfWZ0uG8Yy+DDJjQ=";

  meta = {
    description = "OpenCode plugin that automatically loads direnv environment variables";
    homepage = "https://github.com/simonwjackson/opencode-direnv";
  };
}
