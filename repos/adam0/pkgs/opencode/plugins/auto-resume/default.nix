{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
}:
mkOpencodePlugin rec {
  pname = "auto-resume";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "Mte90";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-6/ifjy9rPfOJlD88IEi58NuB+pvX5PhB417hDeUOsHQ=";
  };

  dependencyHash = "sha256-e52Gddw3FDKju1Ze2sn+/mjpRi8wYs8wuiCQ2T5u6sE=";

  buildCommand = "bun run build";

  meta = {
    description = "OpenCode plugin that automatically resumes stalled LLM sessions.";
    homepage = "https://github.com/Mte90/opencode-auto-resume";
    license = lib.licenses.gpl3Plus;
  };
}
