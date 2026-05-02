# note: this requires a patched nginx/generic.nix
# to use the module attributes configureFlags, src.patchPhase, buildInputs
# see pkgs.nur.repos.milahu.nginx

{
  lib,
  fetchFromGitHub,
  cmark-gfm,
  stdenv,
}:

rec {
  name = "ngx_markdown_filter_module";
  src = (fetchFromGitHub {
    owner = "ukarim";
    repo = "ngx_markdown_filter_module";
    rev = "0.1.7";
    hash = "sha256-OZL0MuATZ1BnSOgJshf0AwQdWJbRkdjClmYVl9BEY+o=";
    /*
    owner = "milahu";
    repo = "ngx_markdown_filter_module";
    # https://github.com/ukarim/ngx_markdown_filter_module/pull/12
    # use cmark-gfm without extra cflags
    rev = "3e0362b4e60c5f26071bfa3d2418ec30cd0d0dbd";
    hash = "sha256-i7orFQEuB9uoFQ+UUdWibJAy26Z6bjGsZqCSWdZ8UhE=";
    */
  }) // {
    patchPhase = ''
      mv config_gfm config
    ''
    /*
      # alternative to -DWITH_CMARK_GFM=1
      sed -i '1 i\#define WITH_CMARK_GFM 1' ngx_markdown_filter_module.c
    */
    +
    # fix: raw HTML omitted
    # FIXME this is insecure
    # https://github.com/commonmark/cmark#security
    # we recommend you use a HTML sanitizer specific to your needs to protect against XSS attacks.
    # FIXME enable the cmark-gfm tagfilter extension
    # https://github.com/github/cmark-gfm/blob/master/extensions/tagfilter.c
    # https://github.github.com/gfm/#disallowed-raw-html-extension-
    # https://github.com/ukarim/ngx_markdown_filter_module/issues/7
    # TODO? also remove dangerous links like <a href="javascript:alert(123)">clickme</a>
    ''
      sed -i 's/CMARK_OPT_DEFAULT/CMARK_OPT_DEFAULT | CMARK_OPT_UNSAFE/' ngx_markdown_filter_module.c
    '';
  };
  buildInputs = [ cmark-gfm ];
  configureFlags = [ "--with-cc-opt=-DWITH_CMARK_GFM=1" ];
  meta = with lib; {
    description = "Markdown-to-html nginx module";
    homepage = "https://github.com/ukarim/ngx_markdown_filter_module";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
  };
}
