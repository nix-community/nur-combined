{
  fetchFromGitLab,
  fetchFromGitea,
  inih,
  lib,
  libdrm,
  libinput,
  libxkbcommon,
  meson,
  ninja,
  pkg-config,
  scdoc,
  stdenv,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "buffybox";
  version = "3.2.0-unstable-2024-11-10";

  # src = fetchFromGitea {
  #   domain = "git.uninsane.org";
  #   owner = "colin";
  #   repo = "buffybox";
  #   fetchSubmodules = true; # to use its vendored lvgl
  #   rev = "a2eef5d356d70f0badb4c99af1cfc32d1898bbda";
  #   hash = "sha256-0XT+cwj3cQ4w++43RAX3fmW5sdgBqiOzz34gM6qLyd4=";
  # };

  src = fetchFromGitLab {
    domain = "gitlab.postmarketos.org";
    owner = "postmarketOS";
    repo = "buffybox";
    fetchSubmodules = true; # to use its vendored lvgl
    rev = "07e324c17564cb9aab573259a8e0824a6806a751";
    hash = "sha256-JY9WqtRjDsQf1UVFnM6oTwyAuhlJvrhcSNJdEZ0zIus=";
  };

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = [
    inih
    libdrm
    libinput
    libxkbcommon
  ];

  strictDeps = true;

  env.PKG_CONFIG_SYSTEMD_SYSTEMD_SYSTEM_UNIT_DIR = "${placeholder "out"}/lib/systemd/system";
  # env.PKG_CONFIG_SYSTEMD_SYSTEMDSYSTEMUNITDIR = "${placeholder "out"}/lib/systemd/system";

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "a suite of graphical applications for the terminal";
    homepage = "https://gitlab.com/postmarketOS/buffybox";
    license = licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
})
