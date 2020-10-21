{ buildVimPluginFrom2Nix, fetchFromGitHub }:

buildVimPluginFrom2Nix {
  pname = "vim-mdx-js";
  version = "2019-03-04";

  src = fetchFromGitHub {
    owner = "jxnblk";
    repo = "vim-mdx-js";
    rev = "17179d7f2a73172af5f9a8d65b01a3acf12ddd50";
    sha256 = "05j2wd1374328x93ymwfzlcqc9z8sc9qbl63lyy62m291yzh5xn1";
  };
}
