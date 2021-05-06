{ stdenv, buildGoModule, fetchFromGitHub, go-rice }:

buildGoModule rec {
  pname = "linx-server";
  version = "2.3.8";

  src = fetchFromGitHub {
    owner = "andreimarcu";
    repo = "linx-server";
    rev = "v${version}";
    sha256 = "00rv13iq8dnws14zghf9p0ja6jj7j66iq9srzmlsjn9pdbr2rkl7";
  };

  vendorSha256 = "14g572xzh8gfy2079d2zhz78h90g86a372hwr8qq1rirnx1x9w98"; 

  subPackages = [ "." ];
  
  runVend = true;

  doCheck = false;

  nativeBuildInputs = [ go-rice ];

  preBuild = "rice embed-go";

  meta = with stdenv.lib; {
    description = "Self-hosted file/media sharing website.";
    homepage = "https://github.com/andreimarcu/linx-server";
    license = licenses.gpl3;
    platforms = platforms.linux ++ platforms.darwin;
  };
}