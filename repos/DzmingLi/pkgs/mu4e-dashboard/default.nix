{
  lib,
  emacsPackages,
  mu,
  fetchFromGitHub,
}:

## rougier/mu4e-dashboard: sidebar-style dashboard for mu4e backed by
## org-mode links — each link is `mu:QUERY|%FORMAT` and gets replaced
## with the formatted count of matching messages.
##
## Consumer pattern (NixOS / home-manager):
##   programs.emacs.package = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages
##     (epkgs: [ ... pkgs.nur.repos.dzmingli.mu4e-dashboard ... ]);
## To pair with a non-default emacs build, override emacsPackages:
##   pkgs.nur.repos.dzmingli.mu4e-dashboard.override {
##     emacsPackages = pkgs.emacsPackagesFor pkgs.emacs-pgtk;
##   }
emacsPackages.trivialBuild {
  pname = "mu4e-dashboard";
  version = "unstable-2024-c9c09b7";

  src = fetchFromGitHub {
    owner = "rougier";
    repo = "mu4e-dashboard";
    rev = "c9c09b7ed6433070de148b656ac273b7fb7cec07";
    sha256 = "164p56i6lgwgg7ina9h5qb4i31q3fngsy0ndbdva9agylk2sa9vc";
  };

  packageRequires = [ emacsPackages.async mu.mu4e ];

  ## pkgs.mu 把 mu4e elisp 装在 share/emacs/site-lisp/mu4e/ 子目录里，
  ## trivialBuild 默认只把 share/emacs/site-lisp 加到 load-path，
  ## byte-compile 时 (require 'mu4e-headers) 找不到。显式加进去。
  preBuild = ''
    export EMACSLOADPATH="${mu.mu4e}/share/emacs/site-lisp/mu4e:$EMACSLOADPATH"
  '';

  meta = with lib; {
    description = "A dashboard for mu4e built around org-mode links";
    homepage = "https://github.com/rougier/mu4e-dashboard";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
