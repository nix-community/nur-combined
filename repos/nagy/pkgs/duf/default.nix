{ stdenv, lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "duf";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "muesli";
    repo = pname;
    rev = "v${version}";
    sha256 = "00qsq63hkv8f4mflgi4lp9znvzk3z6sdkgmq5h2m8vps59zf0vas";
  };

  vendorSha256 = "0icxy6wbqjqawr6i5skwp1z37fq303p8f95crd8lwn6pjjiqzk4i";

  meta = with lib; {
    description = "Disk Usage/Free Utility - a better 'df' alternative";
    homepage = "https://github.com/muesli/duf";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
  };
}
