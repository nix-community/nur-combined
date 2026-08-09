{
  emacsPackages,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
  ...
}:
# emacs-niri-awareness: IPC client for the niri compositor (niri-rpc +
# niri-frame + niri-frame-visible). Personal project, not on MELPA; pin the
# rev. Tests at the repo root would be byte-compiled too, so drop them first.
emacsPackages.trivialBuild {
  pname = "niri-awareness";
  version = "0-unstable-2026-07-31";

  src = fetchFromGitHub {
    owner = "binarin";
    repo = "emacs-niri-awareness";
    rev = "8474ac212d56527507a94c59566273e0735001ac";
    hash = "sha256-+HeWcoPr5ivylZm5xIwgxsnRwmKQ7mkZfWgV7UlkwOM=";
  };

  preBuild = ''
    rm -f ./*-test.el
  '';

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-niri-awareness --version=branch";

  meta = {
    description = "Emacs IPC client for the niri Wayland compositor";
    homepage = "https://github.com/binarin/emacs-niri-awareness";
    # Upstream ships neither a LICENSE file nor per-file license headers, so
    # the exact terms are unknown; the repository is public and unrestricted.
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}
