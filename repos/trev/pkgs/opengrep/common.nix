{lib}: rec {
  version = "1.7.0";

  meta = {
    homepage = "https://github.com/opengrep/opengrep";
    changelog = "https://github.com/opengrep/opengrep/releases/tag/v${version}";
    description = "Static code analysis engine to find security issues in code.";
    license = lib.licenses.lgpl21Plus;
  };
}
