{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "ksuid";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "segmentio";
    repo = pname;
    rev = "v${version}";
    sha256 = "0pvq218cyrwzh113fyfiac69yv5bdc1n6klp7vf7jah3aw6p1aic";
  };

  vendorSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";

  meta = with lib; {
    description = "K-Sortable Globally Unique IDs";
    homepage = "https://github.com/segmentio/ksuid";
    license = with licenses; [ mit ];
  };
}
