{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "ksuid";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "segmentio";
    repo = pname;
    rev = "v${version}";
    sha256 = "1qc9w7imal5jk0lw0hwyszs2fh7wjsnbkawgw7kwzdvg9nbahjg7";
  };

  vendorSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";

  meta = with lib; {
    description = "K-Sortable Globally Unique IDs";
    homepage = "https://github.com/segmentio/ksuid";
    license = with licenses; [ mit ];
  };
}
