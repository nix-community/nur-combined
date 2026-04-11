{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkOpencodePlugin,
  # keep-sorted end
}:
mkOpencodePlugin rec {
  pname = "ignore";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "lgladysz";
    repo = "opencode-${pname}";
    rev = "v${version}";
    hash = "sha256-jqUG0zyYRheAGa+UjZy7twySTXgUzbB+5MK7svis3ss=";
  };

  dependencyHash = "sha256-mqg1Zx4ps51yESFRlvfQFRzO25ndLVnf59fRo15K4ig=";

  buildCommand = "bun run build";

  meta = {
    # keep-sorted start
    description = "OpenCode plugin to restrict AI access to files and directories using .ignore patterns";
    homepage = "https://github.com/lgladysz/opencode-ignore";
    license = lib.licenses.mit;
    # keep-sorted end
  };
}
