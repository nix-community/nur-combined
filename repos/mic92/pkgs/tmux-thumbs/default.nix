{ lib, rustPlatform, fetchFromGitHub }:
rustPlatform.buildRustPackage rec {
  pname = "tmux-thumbs";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "fcsonline";
    repo = "tmux-thumbs";
    rev = version;
    sha256 = "sha256-qxrpfPh9yXowKHwHglSf5s3bnn+U+4T63LRJs6A38+I=";
  };

  cargoSha256 = "sha256-FcQWsg93BLPWsu9f9whUxSKfjYWVhArXB+HTCbapOaw=";

  meta = with lib; {
    description = "A lightning fast version of tmux-fingers written in Rust, copy/pasting tmux like vimium/vimperator";
    homepage = "https://github.com/fcsonline/tmux-thumbs";
    license = licenses.mit;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
