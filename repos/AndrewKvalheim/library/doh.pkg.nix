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
  version = "0.1-unstable-2026-11-23";
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
    rev = "3e00e915a54e4f9cae1ce1068bc3cb55b47ff5d9";
    hash = "sha256-zZMHxXik8fRpxwTQdO9F33JLs7YTNb4vBYS80RKZgwA=";
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
