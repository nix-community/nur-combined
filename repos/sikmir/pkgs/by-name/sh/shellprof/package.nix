{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "shellprof";
  version = "0-unstable-2021-04-27";
  format = "other";

  src = fetchFromGitHub {
    owner = "walles";
    repo = "shellprof";
    rev = "de6999bb37eb132cd18850acc28d988a994f4f86";
    hash = "sha256-SlvQJF2AEvVv4Wt0mwBJ8K5RlHvT8fV5av3w3RuYQ5Q=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase = ''
    install -Dm755 shellprof -t $out/bin
  '';

  meta = {
    description = "Profile a shell script based on its printouts";
    homepage = "https://github.com/walles/shellprof";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
