{
  fetchFromGitLab,
  fetchFromGitea,
  fetchpatch,
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
  version = "3.2.0-unstable-2024-10-05";

  # src = fetchFromGitea {
  #   domain = "git.uninsane.org";
  #   owner = "colin";
  #   repo = "buffybox";
  #   fetchSubmodules = true; # to use its vendored lvgl
  #   rev = "a2eef5d356d70f0badb4c99af1cfc32d1898bbda";
  #   hash = "sha256-0XT+cwj3cQ4w++43RAX3fmW5sdgBqiOzz34gM6qLyd4=";
  # };

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "postmarketOS";
    repo = "buffybox";
    fetchSubmodules = true; # to use its vendored lvgl
    rev = "c683350b9fb944e38cb484f04f98e4e3f85b41a5";
    hash = "sha256-z7siroBDauvs8TxfO/h+5HUU5G5aOWwNUxDaZm80I5A=";
  };

  patches = [
    (fetchpatch {
      url = "https://gitlab.postmarketos.org/postmarketOS/buffybox/-/merge_requests/34.patch";
      name = "add buffyboard systemd service";
      hash = "sha256-FUPDdj9BkC4Mj17X5fZAmIhLHwt8k626OnY07NM14tc=";
    })
  ];

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

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "a suite of graphical applications for the terminal";
    homepage = "https://gitlab.com/postmarketOS/buffybox";
    license = licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
})
