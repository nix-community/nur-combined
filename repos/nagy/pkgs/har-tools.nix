{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "har-tools";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "outersky";
    repo = pname;
    rev = "v${version}";
    sha256 = "1k9sklqrpmkjy41w69nwd520w6n7c7ky6bbv9zwbvg8x6pilw58d";
  };

  vendorSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";

  meta = with lib; {
    description = "tools for HAR file";
    homepage = "https://github.com/outersky/har-tools";
    license = with licenses; [ gpl2 ];
  };
}
