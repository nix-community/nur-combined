{ pkgs,
  lib,
  stdenv,
  fetchgit
}: with lib; let
  pname = "ntfs2btrfs";
  author = "maharmstone";
  version = "20230501";
  src = fetchgit {
    name = "${pname}-${version}.tar.gz";
    url = "https://github.com/${author}/${pname}";
    rev = "refs/tags/${version}";
    sha256 = "sha256-aLk7NsSkXM+6qD3CBQyJ7OhzPo+CUpD17LkQ4fD2iis=";
  };
in stdenv.mkDerivation {
  inherit pname version src;

  buildInputs       = with pkgs; [
    lzo
    zlib
    zstd
    pkgs.fmt_9
  ];
  nativeBuildInputs = with pkgs; [ 
    pkg-config
    cmake
  ];

  meta = with lib; {
    description = "Ntfs2btrfs is a tool which does in-place conversion of Microsoft's NTFS filesystem to the open-source filesystem Btrfs";
    homepage    = "https://github.com/maharmstone/ntfs2btrfs/";
    license     = licenses.gpl2Only;
  };
}

