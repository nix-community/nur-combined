{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule {
  pname = "koneko";
  version = "unstable-2021-06-15";

  src = fetchFromGitHub {
    owner = "irevenko";
    repo = "koneko";
    # No releases
    rev = "cc3a8d2a609f19064ab42c9e903fef10935a8e1f";
    sha256 = "1x73bnwxcv3846h2d7hsh3vfmvpxyl698bcd0956s4zq56p07q16";
  };

  vendorSha256 = "0kiq3k3vnnn8w8g8c3mzmzw2cripr1j5ld5pxcgvas5ycmzkyycv";

  meta = with lib; {
    description = "nyaa.si terminal BitTorrent tracker";
    homepage = "https://github.com/irevenko/koneko";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ artturin ];
  };
}
