{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "auto-resume";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "Mte90";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-ekZ1IHFm2OG65lMBXg9G+2GaurDwhiiAjqtQqtRRrvk=";
  };

  dependencyHash = "sha256-e52Gddw3FDKju1Ze2sn+/mjpRi8wYs8wuiCQ2T5u6sE=";

  buildCommand = "bun run build";

  meta = {
    # keep-sorted start
    description = "OpenCode plugin that automatically resumes stalled LLM sessions.";
    homepage = "https://github.com/Mte90/opencode-auto-resume";
    license = lib.licenses.gpl3Plus;
    # keep-sorted end
  };
}
