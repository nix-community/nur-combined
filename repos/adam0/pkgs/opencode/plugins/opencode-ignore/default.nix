{
  lib,
  fetchFromGitHub,
  mkOpencodePlugin,
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

  postInstall = ''
    cd "$out"
    bun run build
  '';

  meta = {
    description = "OpenCode plugin that blocks access to paths matched by .ignore patterns";
    homepage = "https://github.com/lgladysz/opencode-ignore";
    license = lib.licenses.mit;
  };
}
