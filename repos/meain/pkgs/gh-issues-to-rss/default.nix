{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gh-issues-to-rss";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "gh-issues-to-rss";
    rev = "${version}";
    sha256 = "sha256-cZKCwPIyAVwNeNC+uSThqupRq2bFSg0ZVqRhQa8/UOY=";
  };

  vendorSha256 = "sha256-ZLFD1ynNgsm8i3nACx/SSA68gsNUto3ZFpUF0aNnDGA=";
  proxyVendor = true;

  postInstall = ''
    mkdir -p $out
    cp index.html $out/index.html
  '';

  meta = with lib; {
    description = "Convert Github issues and PRs into an rss feed";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/gh-issues-to-rss";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
