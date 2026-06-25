{
  lib,
  emacsPackages,
  fetchFromGitHub,
  tree-sitter,
}:

## tonyfettes/moonbit-mode: MoonBit major mode，tree-sitter 高亮 + eglot
## (moonbit-lsp) 集成，含 semantic tokens 增强高亮和 moon build/check/test
## project 命令。
##
## tree-sitter grammar 不在 nixpkgs（treesit-grammars.with-all-grammars 不含
## moonbit），所以这里随 elisp 一起构建并链到 $out/lib/。emacsWithPackages
## 会把各 elisp 包的 lib/ 合并进 emacs-packages-deps/lib 并将其加入
## treesit-extra-load-path，Emacs 的 treesit 即可找到
## libtree-sitter-moonbit{,_mbtp}.so。
##
## Consumer pattern 同 mu4e-dashboard：
##   programs.emacs.package = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages
##     (epkgs: [ ... pkgs.nur.repos.dzmingli.moonbit-mode ... ]);
let
  tree-sitter-moonbit-src = fetchFromGitHub {
    owner = "moonbitlang";
    repo = "tree-sitter-moonbit";
    rev = "ebdb3f38d46309a3a7f81c2af357da05ec8a4470";
    sha256 = "1wssip439hwf4s9nn0314ilf28fn8ksaqjl7np7686zfccrjdp35";
  };

  grammar-moonbit = tree-sitter.buildGrammar {
    language = "moonbit";
    version = "0-unstable-2026-05-21";
    src = tree-sitter-moonbit-src;
  };

  ## .mbtp 谓词/证明文件用独立 grammar，moonbit-mode 按扩展名选
  ## 'moonbit_mbtp 语言，对应 libtree-sitter-moonbit_mbtp.so。
  grammar-mbtp = tree-sitter.buildGrammar {
    language = "moonbit_mbtp";
    version = "0-unstable-2026-05-21";
    src = tree-sitter-moonbit-src;
    location = "grammars/mbtp";
  };
in
emacsPackages.trivialBuild {
  pname = "moonbit-mode";
  version = "0.1.0-unstable-2026-05-17";

  src = fetchFromGitHub {
    owner = "tonyfettes";
    repo = "moonbit-mode";
    rev = "b74d2bac952a4fe49ada431fe473df884dc99a65";
    sha256 = "16q1kfmlxgb5k6506csqm0m16qhx30a8ya044zqn1qzxml3gxyaq";
  };

  postInstall = ''
    mkdir -p $out/lib
    ln -s ${grammar-moonbit}/parser $out/lib/libtree-sitter-moonbit.so
    ln -s ${grammar-mbtp}/parser $out/lib/libtree-sitter-moonbit_mbtp.so
  '';

  passthru = { inherit grammar-moonbit grammar-mbtp; };

  meta = with lib; {
    description = "MoonBit major mode for Emacs with tree-sitter highlighting and Eglot support";
    homepage = "https://github.com/tonyfettes/moonbit-mode";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
