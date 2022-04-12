# nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
# ./result/bin/archive-org-downloader.py

{ lib, fetchFromGitHub, python3Packages }:
with python3Packages;
buildPythonApplication {
  pname = "archive-org-downloader";
  version = "2021-09-19";
  propagatedBuildInputs = [
    requests
    tqdm
    img2pdf
  ];
  src = fetchFromGitHub {
    repo = "Archive.org-Downloader";
    /*
    owner = "MiniGlome";
    rev = "8a101d5303f41d96c4300dd76237acd312e6a17d";
    sha256 = "04wh5makv2cncbgiv739nf1hrzr5nx71a0bnj7dflxj5fw1miw9d";
    */
    # https://github.com/MiniGlome/Archive.org-Downloader/pull/9
    #   add setup.py
    #   add shebang
    #   remove \r
    #   make executable
    # maintainer is ignoring my patch. fork: https://github.com/milahu/Archive.org-Downloader
    owner = "milahu";
    rev = "b9a6280cc70c3b138827b747b21ff02dfcb68e30";
    sha256 = "0bkyn1agn4lhfydrjavkwawyazd13jy5vn4wbmr9qs5yivacgwqh";
  };
  meta = with lib; {
    description = "download books from archive.org";
    homepage = "https://github.com/MiniGlome/Archive.org-Downloader";
    #license = licenses.mit; # no license
    platforms = platforms.all;
  };
}
