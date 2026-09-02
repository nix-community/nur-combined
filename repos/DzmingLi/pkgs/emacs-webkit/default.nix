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

    ## ---- mu4e/elfeed 预览内存封顶：webkit-module.c 两处 ----
    ## 复用单个 webview 连续 load 几十封图片重的 newsletter，WebKitWebProcess
    ## 只涨不收（实测 ~2h 到 545MB）。从 WebKit 源头两手：cache model 掐缓存、
    ## 暴露 terminate-web-process 给 elisp 周期回收（见 webkit-html.el）。

    ## A1. cache model 设 DOCUMENT_VIEWER：邮件预览器不需要持久缓存，从源头
    ## 掐断页面/网络缓存随预览数无限增长。
    substituteInPlace webkit-module.c \
      --replace-fail 'WebKitWebContext *context = webkit_web_context_new ();' \
                     'WebKitWebContext *context = webkit_web_context_new ();
  webkit_web_context_set_cache_model (context, WEBKIT_CACHE_MODEL_DOCUMENT_VIEWER);'

    ## A2a. 新增 webkit_terminate_web_process（仿 webkit_reload）：杀掉 webview
    ## 的 web process，下次 load 自动重起，透明释放累积内存、webview 不死。
    substituteInPlace webkit-module.c \
      --replace-fail 'webkit_reload (emacs_env *env, ptrdiff_t n, emacs_value *args, void *ptr)' \
                     'webkit_terminate_web_process (emacs_env *env, ptrdiff_t n, emacs_value *args, void *ptr)
{
  Client *c = get_client (env, args[0]);
  if (c != NULL)
    webkit_web_view_terminate_web_process (c->view);
  return Qnil;
}

static emacs_value
webkit_reload (emacs_env *env, ptrdiff_t n, emacs_value *args, void *ptr)'

    ## A2b. 注册到 elisp 名 webkit--terminate-web-process。
    substituteInPlace webkit-module.c \
      --replace-fail '  mkfn (env, 1, 1, webkit_reload, "webkit--reload", "", NULL);' \
                     '  mkfn (env, 1, 1, webkit_reload, "webkit--reload", "", NULL);
  mkfn (env, 1, 1, webkit_terminate_web_process, "webkit--terminate-web-process", "", NULL);'
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
