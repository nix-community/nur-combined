{
  cmake,
  enableVmaf ? true,
  fetchFromGitHub,
  gitUpdater,
  lib,
  libvmaf,
  perl,
  pkg-config,
  python3,
  stdenv,
  versionCheckHook,
  yasm,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "avm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "AOMediaCodec";
    repo = "avm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dmMQfOP71DdjHZw6DpbiiOB5a9khIu6QnZ0F5WsMuM8=";
  };

  postPatch = ''
    substituteInPlace cmake/pkg_config.cmake \
      --replace-fail \
        'file(APPEND "''${pkgconfig_file}" "libdir=\''${exec_prefix}/''${libdir}\n\n")' \
        'file(APPEND "''${pkgconfig_file}" "libdir=\''${CMAKE_INSTALL_FULL_LIBDIR}\n\n")'

    substituteInPlace cmake/pkg_config.cmake \
      --replace-fail \
        'file(APPEND "''${pkgconfig_file}" "includedir=\''${prefix}/''${includedir}\n")' \
        'file(APPEND "''${pkgconfig_file}" "includedir=\''${CMAKE_INSTALL_FULL_INCLUDEDIR}\n")'
  '';

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    cmake
    perl
    pkg-config
    python3
    yasm
  ];

  propagatedBuildInputs = lib.optional enableVmaf libvmaf;
  cmakeFlags = lib.optional enableVmaf (lib.cmakeFeature "CONFIG_TUNE_VMAF" "1");

  postInstall = ''
    mv $out/$out/* $out/
    rm -r $out/nix
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    homepage = "https://github.com/AOMediaCodec/avm";
    description = "AVM (AOM Video Model) is the reference software for AV2 codec from Alliance for Open Media";
    changelog = "https://github.com/AOMediaCodec/avm/blob/${finalAttrs.src.tag}/CHANGELOG";
    license = lib.licenses.bsd3Clear;
    maintainers = [
      {
        email = "vgrechannik@gmail.com";
        name = "Vladislav Grechannik";
        github = "VlaDexa";
        githubId = 52157081;
      }
    ];
    mainProgram = "avmenc";
  };
})
