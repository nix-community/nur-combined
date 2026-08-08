{
  # keep-sorted start
  cacert,
  fetchFromGitHub,
  lib,
  rustPlatform,
  # keep-sorted end
}:
rustPlatform.buildRustPackage rec {
  pname = "smelt";
  version = "0.5.0-alpha.9";

  src = fetchFromGitHub {
    owner = "leonardcser";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-LQvyshYU5BgeTpkrMF+XRf+IjVR4DYDnVczjSVO9/xI=";
  };

  cargoHash = "sha256-MTVQoZduiOCjiCJkOnSRvSAVtPVw6gxX0ZFXW9NdKmg=";

  nativeCheckInputs = [cacert];
  SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR"
    $out/bin/smelt --version
  '';

  meta = {
    # keep-sorted start
    description = "Small, fast, and Lua-scriptable coding agent";
    homepage = "https://github.com/leonardcser/smelt";
    license = lib.licenses.mit;
    mainProgram = "smelt";
    platforms = lib.platforms.unix;
    # keep-sorted end
  };
}
