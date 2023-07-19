{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "gh-issues-to-rss";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "gh-issues-to-rss";
    rev = "${version}";
    sha256 = "sha256-DRJ6opCIiEF/dLdwX28J0zQKJ5BJO2zJIkNRL/W4kew=";
  };

  vendorSha256 = "sha256-Zdg+IXjGluV5sOORcq9M0FKxfstBu64VdKb9jkrS0Rw=";
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
