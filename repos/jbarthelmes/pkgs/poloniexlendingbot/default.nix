{ writeShellScriptBin, python, fetchFromGitHub }:
let
  pname = "poloniexlendingbot";
  commit = "cadbc7c4";
  version = "git-${commit}";

  src = fetchFromGitHub {
    owner = "BitBotFactory";
    repo = pname;
    rev = commit;
    sha256 = "191g29q30q7zz3i5cpy42pa3nxs7pxxn48k0q60svhikmy2axhp3";
  };

in
writeShellScriptBin "poloniexlendingbot" "${python}/bin/python ${src}/lendingbot.py $*"
