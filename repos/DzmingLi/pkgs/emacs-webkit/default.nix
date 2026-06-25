{
  lib,
  emacsPackages,
  fetchFromGitHub,
  pkg-config,
  webkitgtk_4_1,
  glib,
  gtk3,
  gobject-introspection,
}:

## akirakyle/emacs-webkit: dynamic module bringing WebKitGTK as a real
## browser widget inside an Emacs window — works on pgtk Wayland where
## the built-in xwidget-webkit historically didn't.
##
## Consumer pattern (NixOS / home-manager):
##   programs.emacs.package = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages
##     (epkgs: [ ... pkgs.nur.repos.dzmingli.emacs-webkit ... ]);
## On non-default emacs builds (e.g. emacs-pgtk), override trivialBuild:
##   pkgs.nur.repos.dzmingli.emacs-webkit.override {
##     emacsPackages = pkgs.emacsPackagesFor pkgs.emacs-pgtk;
##   }
emacsPackages.trivialBuild {
  pname = "emacs-webkit";
  version = "unstable-2026-05-11";

  src = fetchFromGitHub {
    owner = "akirakyle";
    repo = "emacs-webkit";
    rev = "4c5caa8e2c2baa09400d3c4a467d4799d735d388";
    hash = "sha256-bHrfc9bGKY57+KGDRH5CdRflWH5va4jzGkMzXRrapg4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ webkitgtk_4_1 glib gtk3 gobject-introspection ];

  ## Upstream Makefile hardcodes `LIBS = gtk+-3.0 webkit2gtk-4.0`, but
  ## nixpkgs only ships webkit2gtk-4.1 now (4.0 dropped). API differences
  ## are minimal (mostly libsoup2 → libsoup3 ABI), so just rewrite the pkg name.
  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'webkit2gtk-4.0' 'webkit2gtk-4.1'

    ## 删掉开发者 scratch 和需要外部依赖的可选模块，避免 emacsWithPackages
    ## 的 native-compile pass 把它们也编一遍：
    ##   tests.el                   —— 顶层引用 ~/git/... 撞 /homeless-shelter
    ##   webkit-ace.el              —— 依赖 ace-window
    ##   evil-collection-webkit.el  —— 依赖 evil-collection
    rm -f tests.el webkit-ace.el evil-collection-webkit.el

    ## webkit.el 顶层就调 (make-directory (locate-user-emacs-file "webkit/") t)，
    ## emacsWithPackages 的 native-compile pass 在 sandbox 里跑（HOME=/homeless-shelter），
    ## 撞 permission-denied。包到 noninteractive 检查里：批模式不建目录，
    ## emacs 正常启动时再建。
    substituteInPlace webkit.el \
      --replace-fail '(make-directory webkit--user-dir t)' \
                     '(unless noninteractive (make-directory webkit--user-dir t))'

    ## webkit.el 顶层还调 (org-link-set-parameters ...) 注册 org link 类型，
    ## 但 `ol` 包不在 native-compile 上下文里 → void-function。
    ## with-eval-after-load 'ol 让它推迟到 org-link 加载后再注册。
    substituteInPlace webkit.el \
      --replace-fail "(org-link-set-parameters \"webkit\" :store #'webkit-org-store-link)" \
                     "(with-eval-after-load 'ol (org-link-set-parameters \"webkit\" :store #'webkit-org-store-link))"
  '';

  ## trivialBuild 默认 buildPhase 是 batch-byte-compile *.el，会跑两次（先它，
  ## 后 make 我们要的）。覆盖：先 make 出 webkit-module.so，再 byte-compile。
  buildPhase = ''
    runHook preBuild
    make
    emacs -L . --batch \
      --eval "(setq byte-compile-error-on-warn nil)" \
      -f batch-byte-compile *.el
    runHook postBuild
  '';

  ## 覆盖 installPhase：除了 .el / .elc，还要把 webkit-module.so 和 hints.{js,css}
  ## 装到 $LISPDIR。必须在这里装（不能 postInstall），因为 generic.nix 的 postInstall
  ## 提前 prepend 了 native-compile pass，那时 webkit.el (require 'webkit-module)
  ## 需要 .so 已经在 load-path 上。
  installPhase = ''
    runHook preInstall

    LISPDIR=$out/share/emacs/site-lisp
    install -d $LISPDIR
    install -m644 *.el *.elc       $LISPDIR
    install -m755 webkit-module.so $LISPDIR
    install -m644 hints.js hints.css $LISPDIR

    runHook postInstall
  '';

  meta = with lib; {
    description = "Emacs dynamic module wrapping WebKitGTK as a real browser widget";
    homepage = "https://github.com/akirakyle/emacs-webkit";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
