{
  lib,
  fetchFromGitHub,
  python3,
  apt,
  dpkg,
  zstd,
  util-linux,
  systemd,
  debootstrap,
  nix-update-script,
  versionCheckHook,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "debspawn";
  version = "0.6.5";
  pyproject = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "lkhq";
    repo = "debspawn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cDc9xmZZd7cU72HqcNQI1ej6A1GSAmMJiRB6y9WTRoQ=";
  };

  build-system = with python3.pkgs; [
    setuptools
    pkgconfig
  ];

  dependencies = with python3.pkgs; [ tomlkit ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  # systemd-nspawn keeps the PATH variable intact, which is a problem for Nix
  postPatch = ''
    substituteInPlace debspawn/dsrun \
      --replace-fail \
        "os.environ['SHELL'] = '/bin/sh'" \
        "os.environ['SHELL'] = '/bin/sh'; os.environ['PATH'] = '/usr/sbin:/usr/bin:/sbin:/bin'"
  '';

  # dsrun is mounted inside the container, so it must keep its shebang
  postFixup = ''
    sed -i '1s|.*|#!/usr/bin/python3|' $out/${python3.sitePackages}/debspawn/dsrun
  '';

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      dpkg
      debootstrap
      util-linux # findmnt
      zstd
      systemd # systemd-nspawn
    ])
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Debian package builder and build helper using systemd-nspawn";
    homepage = "https://github.com/lkhq/debspawn";
    mainProgram = "debspawn";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.linux;
  };
})
