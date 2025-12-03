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
    # rev = "0.1.3";
    # https://github.com/ukarim/ngx_markdown_filter_module/pull/6
    rev = "11eef87a7966a72cbd10da1f80472b8b3a24c198";
    hash = "sha256-Ap22bM2HZ/F0WjkdQSPF4XcowxclE2b45jaL5MvNF1A=";
  }) // {
    patchPhase = ''
      mv config_gfm config
    ''
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
