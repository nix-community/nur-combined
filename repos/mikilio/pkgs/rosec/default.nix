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
    tag = "v${version}";
    hash = "sha256-xo9JKSpr+RRqvM8JIypdUcPo3AmDLZ7u1LwH1+rCrOI=";
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

    cargoHash = "sha256-xybN+JOIhtAUtlraILfDJfpfOjmxdtzX4oFVZAloeHQ=";

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
  version = "0.0.25";

  paths = [rosec rosec_pam] ++ provider;

  passthru = {
    inherit (rosec) src;
  };

  meta = {
    description = "A secrets daemon implementing the freedesktop.org Secret Service API with modular backend providers";
    homepage = "https://github.com/jmylchreest/rosec";
    license = lib.licenses.mit;
    maintainers = [];
    platforms = lib.platforms.linux;
    mainProgram = "rosec";
  };
})
