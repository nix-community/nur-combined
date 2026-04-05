{
  lib,
  fetchFromGitHub,
  rustPlatform,
  rustc,
  stdenv,
  autoPatchelfHook,
  symlinkJoin,
  pam,
  wayland,
  libxkbcommon,
  provider ? [],
}:
symlinkJoin (finalAttrs: let
  inherit (finalAttrs) version;

  src = fetchFromGitHub {
    owner = "jmylchreest";
    repo = "rosec";
    # tag = "v${version}";
    rev = "b4010d9907d66b3e9835698b391a61fdefcd5bd8";
    hash = "sha256-+jmJtnLVpswGNv8VGqcNc/8ePS6kguDhQXLPLWJb0no=";
  };

  rosec_pam = stdenv.mkDerivation {
    pname = "pam_rosec";
    inherit version src;
    sourceRoot = "${src.name}/contrib/pam";

    buildInputs = [pam];

    makeFlags = [
      "PREFIX=$(out)"
      "ROSEC_PAM_UNLOCK_PATH=${rosec}/libexec/rosec/rosec-pam-unlock"
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 pam_rosec.so "$out/lib/security/pam_rosec.so"
      runHook postInstall
    '';
  };

  rosec = rustPlatform.buildRustPackage {
    pname = "rosec-unwrapped";
    inherit version src;

    cargoHash = "sha256-CdCVrwcimnU0rlZWU5bgaEJiNIgRX6Ba6MJkOFtcPtU=";

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    runtimeDependencies = [
      libxkbcommon
      wayland
    ];

    buildInputs = [
      stdenv.cc.cc.lib
    ];

    postPatch = ''
      substituteInPlace Cargo.toml \
        --replace-fail 'rust-version = "1.93"' 'rust-version = "${rustc.version}"'
    '';

    checkFlags = [
      "--skip=state::"
      "--skip=item::"
      "--skip=portal::"
    ];

    postInstall = ''
      mkdir -p $out/libexec/rosec
      mkdir -p $out/lib/rosec/providers
      mkdir -p $out/share/dbus-1/system.d
      mkdir -p $out/share/systemd/user

      mv $out/bin/rosec-pam-unlock $out/libexec/rosec/

      XDG_CONFIG_HOME=$out/lib XDG_DATA_HOME=$out/share $out/bin/rosec enable
    '';
  };
in {
  pname = "rosec";
  version = "0.0.23";

  paths = [rosec rosec_pam] ++ provider;

  meta = {
    description = "A secrets daemon implementing the freedesktop.org Secret Service API with modular backend providers";
    homepage = "https://github.com/jmylchreest/rosec";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "rosec";
  };
})
