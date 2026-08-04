{ fetchFromGitHub
, lib
, stdenv
, unstableGitUpdater
, versionCheckHook

  # Dependencies
, curl
}:

let
  inherit (lib) licenses;
in
stdenv.mkDerivation {
  pname = "doh";
  version = "0.1-unstable-2026-04-28";
  meta = {
    description = "Stand-alone application for DoH (DNS-over-HTTPS) name resolves and lookups";
    homepage = "https://github.com/curl/doh";
    license = licenses.mit;
    mainProgram = "doh";
  };

  passthru.updateScript = unstableGitUpdater { tagPrefix = "doh-"; };

  src = fetchFromGitHub {
    owner = "curl";
    repo = "doh";
    rev = "69895137f92407ae94b4f3b7ff2aa4be98eb1f20";
    hash = "sha256-OZBufmM8CyvhTwVo1oRNo4LCd8Oj4J5ZolBWK7XOOMw=";
  };

  nativeBuildInputs = [ curl ];

  preInstall = ''
    mkdir --parents "$out/share/man/man1"
  '';
  installFlags = [
    "BINDIR=$(out)/bin"
    "MANDIR=$(out)/share/man"
  ];
  # doInstallCheck = true; # Pending stable version
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-V";
}
