{
  stdenv,
  cmake,
  yasm,
  perl,
  pkg-config,
  fetchFromGitHub,
  python3,
  lib,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "avm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "AOMediaCodec";
    repo = "avm";
    rev = "v${finalAttrs.version}";
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

  nativeBuildInputs = [
    cmake
    yasm
    perl
    python3
    pkg-config
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
