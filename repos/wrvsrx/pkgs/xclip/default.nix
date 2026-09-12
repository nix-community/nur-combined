{ xclip, fetchFromGitHub }:
# To fix https://github.com/astrand/xclip/issues/131
xclip.overrideAttrs (old: {
  version = old.version + "-unstable-2022-01-29";

  src = fetchFromGitHub {
    owner = "astrand";
    repo = "xclip";
    rev = "b372f73579d30f9ba998ffd0a73694e7abe2c313";
    hash = "sha256-pBGRV2h7JiNZ4Im3NySEq1UGNW65MpvTjpTxy0m8jc4=";
  };
})
