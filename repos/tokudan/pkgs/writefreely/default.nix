{ stdenv, lib, fetchFromGitHub, fetchurl, buildGoModule, go-bindata,
}:

buildGoModule rec {
  name = "writefreely-${version}";
  version = "0.13.1";

  src = fetchFromGitHub {
    owner = "writeas";
    repo = "writefreely";
    rev = "v${version}";
    sha256 = "0w51gvw153rp9r1b595rzvs869avaq589vmypsyw3fxz6251x1x9";
  };

  assets = fetchurl {
    url = "https://github.com/writeas/writefreely/releases/download/v${version}/writefreely_${version}_linux_amd64.tar.gz";
    sha256 = "18k85plnfd5zcj58dan2mxxrwabvjk3ih3yi9mx35idwj4pwr14c";
  };

  buildInputs = [ go-bindata ];

  vendorSha256 = "08bwrpyv2cda8s6ag4xl3mdx4hyy3qjzp0j9l3simxnarnsyy4q8";
  subPackages = [ "cmd/writefreely/" ];

  preBuild = ''
    ${go-bindata}/bin/go-bindata -pkg writefreely -ignore=\\.gitignore -tags="!wflib" schema.sql sqlite.sql
    '';
  buildFlagsArray = [ "-tags='sqlite'" ];
  postInstall = ''
    mkdir -p $out/lib
    cd $out/lib
    tar xavf ${assets} --strip-components=1 writefreely/{pages,static,templates}
    '';

  meta = with lib; {
    broken = false;
    description = "A simple, federated blogging platform";
    homepage = https://writefreely.org;
    license = licenses.agpl3;
    maintainers = with maintainers; [ tokudan ];
    platforms = platforms.linux;
  };
}

