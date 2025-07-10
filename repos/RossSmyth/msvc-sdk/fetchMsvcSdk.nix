{
  lib,
  stdenvNoCC,
  replaceVars,
  fetchFromGitHub,
  nix-update-script,
  makeBinaryWrapper,
  python3,
  msitools,
  git,
  cacert,
  perl,
  wine64,
}:
stdenvNoCC.mkDerivation {
  pname = "fetchMsvcSdk";
  version = "0-unstable-2025-06-09";

  src = fetchFromGitHub {
    owner = "mstorsjo";
    repo = "msvc-wine";
    rev = "cb78cc0bc91a9e3da69989b76b99d6f44a7d1a69";
    hash = "sha256-oeaM9Djlnyv3lBTPmKrPefvqaL0tnY1an6/CXpq0z1c=";
  };

  patches = [
    # Patch up the paths for various programs
    (replaceVars ./interpreters.patch {
      MSIEXEC = lib.getExe' msitools "msiexec";
      MSIEXTRACT = lib.getExe' msitools "msiextract";
      GIT = lib.getExe git;
      WINE = lib.getExe wine64;
    })

    # 1. Enable shopt glob extensions
    # 2. Put the tmp file into $TMPDIR
    # 3. Copy everything in the wrapper directory except the wrapper that will be created.
    # 4. Substitute in Wine's executable path
    # 5. Output wine stdout for diagnostics
    #
    # For some reason I get permission denied if #3 is not done.
    (replaceVars ./install.patch {
      WINE = lib.getExe wine64;
    })

    # For some reason this tries to look up "echo" with /usr/bin/env. Which doesn't work on Nix.
    # but it's a coreutil so it's always avaliable.
    # I also enable `set -euo pipefail` just in case.
    ./msvcenv.patch
  ];

  nativeBuildInputs = [ makeBinaryWrapper ];
  buildInputs = [
    msitools
    python3
    cacert
    perl
    wine64
  ];

  dontBuild = true;
  preInstall = ''
    mkdir -p $out
    mv ./* $out
  '';
  postInstall = ''
    mv $out/vsdownload.py $out/.vsdownload.py

    makeWrapper ${python3.interpreter} "$out/vsdownload.py" \
      --add-flags "$out/.vsdownload.py" \
      --set NIX_SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt \
      --set SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt
  '';

  passthru.updateScript = nix-update-script { extraArgs = "--version=branch"; };

  meta = {
    description = "Essentially a fetcher for the MSVC SDK";
    homepage = "https://github.com/mstorsjo/msvc-wine/";
    license = lib.licenses.isc;
    mainProgram = "vsdownload.py";
    maintainers = with lib.maintainers; [ RossSmyth ];
  };
}
