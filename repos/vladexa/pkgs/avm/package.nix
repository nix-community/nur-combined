{
  stdenv,
  cmake,
  yasm,
  perl,
  pkg-config,
  fetchFromGitLab,
  python3,
  lib,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "avm";
  version = "12.0.0";

  src = fetchFromGitLab {
    owner = "AOMediaCodec";
    repo = "avm";
    rev = "research-v${finalAttrs.version}";
    hash = "sha256-Ja5friYDu28uSII2IJHAD/m9p6P8PE10Sozrl24W3Ps=";
  };

  postPatch = ''
    substituteInPlace build/cmake/pkg_config.cmake \
      --replace-fail \
        'file(APPEND "''${pkgconfig_file}" "libdir=\''${exec_prefix}/''${libdir}\n\n")' \
        'file(APPEND "''${pkgconfig_file}" "libdir=\''${CMAKE_INSTALL_FULL_LIBDIR}\n\n")'

    substituteInPlace build/cmake/pkg_config.cmake \
      --replace-fail \
        'file(APPEND "''${pkgconfig_file}" "includedir=\''${prefix}/''${includedir}\n")' \
        'file(APPEND "''${pkgconfig_file}" "includedir=\''${CMAKE_INSTALL_FULL_INCLUDEDIR}\n")'
  '';

  nativeBuildInputs = [
    cmake
    yasm
    perl
    python3
    pkg-config
  ];

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  postInstall = ''
    mv $out/$out/* $out/
    rm -r $out/nix
  '';

  meta = {
    homepage = "https://gitlab.com/AOMediaCodec/avm";
    description = "AVM (AOM Video Model) is the reference software for next codec from Alliance for Open Media";
    license = lib.licenses.bsd3Clear;
    maintainers = [
      {
        email = "vgrechannik@gmail.com";
        name = "Vladislav Grechannik";
        github = "VlaDexa";
        githubId = 52157081;
      }
    ];
  };
})
