{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,
  pam,
  # dbus,
}:
rustPlatform.buildRustPackage (finalAttrs: let
  version = "0.0.21";

  src = fetchFromGitHub {
    owner = "jmylchreest";
    repo = "rosec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lQqA2KvEVYJuzwolw/8oVFEqQ06WC3mDa6dgVitgfoA=";
    # rev = "6edb27fe43affb9ffcd891e373bc451ebdcd77";
    # hash = "sha256-Q1LWKNwAXf2WlnywWHr+Gv+DTTqJFJdlyIKxmyHWJqg=";
  };

  pamModule = stdenv.mkDerivation {
    pname = "pam_rosec";
    inherit version src;
    sourceRoot = "${src.name}/contrib/pam";
    buildInputs = [
      pam
    ];
    makeFlags = [
      "PREFIX=$(out)"
      "ROSEC_PAM_UNLOCK_PATH=$(out)/libexec/rosec/rosec-pam-unlock"
    ];
    installPhase = ''
      runHook preInstall

      install -Dm755 pam_rosec.so "$out/lib/security/pam_rosec.so"

      runHook postInstall
    '';
  };
in {
  pname = "rosec";

  inherit src version;

  cargoHash = "sha256-Aeufqe1F9xXhGd68+sW3tPT7VAXGZfinkgJSUPwT40Q=";
  # cargoHash = "sha256-3nIv29IEYRO6AcsQ8En+leSkZ+fkYZU5osoAwV/M41Y=";

  buildInputs = [
    pamModule
  ];

  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'rust-version = "1.93"' 'rust-version = "1.91"'
  '';

  checkFlags = [
    "--skip=state::"
    "--skip=item::"
  ];

  # nativeCheckInputs = [dbus];
  #
  # preCheck = ''
  #   export HOME=$(mktemp -d)
  #   export XDG_RUNTIME_DIR=$(mktemp -d)
  #
  #   # Start a session D-Bus daemon
  #   eval $(dbus-launch --sh-syntax)
  # '';
  #
  # postCheck = ''
  #   kill $DBUS_SESSION_BUS_PID || true
  # '';

  postInstall = ''
    mkdir -p $out/libexec/rosec/
    mkdir -p $out/lib/security/
    cp ${pamModule}/lib/security/pam_rosec.so $out/lib/security/pam_rosec.so
    mv $out/bin/rosec-pam-unlock $out/libexec/rosec/
  '';

  meta = {
    description = "A secrets daemon implementing the freedesktop.org Secret Service API with modular backend providers ";
    homepage = "https://github.com/jmylchreest/rosec";
    license = lib.licenses.mit;
    maintainers = [];
  };
})
