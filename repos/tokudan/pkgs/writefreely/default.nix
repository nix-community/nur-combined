{ stdenv, lib, fetchFromGitHub, fetchurl, buildGoModule, go-bindata,
}:

buildGoModule rec {
  name = "writefreely-${version}";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "writeas";
    repo = "writefreely";
    rev = "v${version}";
    sha256 = "1h6mcsb74ybp4dksylh2avyvgcrc232ny9l1075pmslhqr85kbvv";
  };

  assets = fetchurl {
    url = "https://github.com/writeas/writefreely/releases/download/v${version}/writefreely_${version}_linux_amd64.tar.gz";
    sha256 = "0kahp93jj6irgcl692ddd7p87zh7gxwrs3arw5lbrf77jr1jgvkm";
  };

  buildInputs = [ go-bindata ];

  modSha256 = "140rh8hfz133flng72j4p9zsmvv05i0330ngsz4b90p2kaavfqqz";
  preBuild = ''
    go-bindata -pkg writefreely -ignore=\\.gitignore -tags="!wflib" schema.sql sqlite.sql
    '';
  buildFlagsArray = [ "-tags='sqlite'" ];
  postInstall = ''
    mkdir -p $out/lib
    cd $out/lib
    tar xavf ${assets} --strip-components=1 writefreely/{pages,static,templates}
    '';

  meta = with lib; {
    broken = true;
    description = "A simple, federated blogging platform";
    homepage = https://writefreely.org;
    license = licenses.agpl3;
    maintainers = with maintainers; [ tokudan ];
    platforms = platforms.linux;
  };
}

