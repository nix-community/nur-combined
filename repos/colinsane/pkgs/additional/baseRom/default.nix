# "baseRom" is used by `sm64ex`, `sm64ex-coop`: broken packages which fail to provide this dependency
{ fetchurl }:
fetchurl {
  url = "https://github.com/jb1361/Super-Mario-64-AI/raw/development/Super%20Mario%2064%20(USA).z64";
  hash = "sha256-F84Hc0PGEz+Mny1tbZpKtiyM0qpXxArqH0kLTIuyHZE=";
}
