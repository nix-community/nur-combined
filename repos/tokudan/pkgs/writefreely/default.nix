{ stdenv, lib, fetchFromGitHub, fetchurl, buildGoModule, go-bindata,
}:

buildGoModule rec {
  name = "writefreely-${version}";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "writeas";
    repo = "writefreely";
    rev = "v${version}";
    sha256 = "1594s38ryw97vggki9mrn6pfqz1acacpsjw4g0sz3imp7dy53fp8";
  };

  assets = fetchurl {
    url = "https://github.com/writeas/writefreely/releases/download/v${version}/writefreely_${version}_linux_amd64.tar.gz";
    sha256 = "04y6f32w2v3hsizclg41gdb7pgvpnd4dmjpwkzf8kxxk3jhwsqwm";
  };

  buildInputs = [ go-bindata ];

  vendorSha256 = "0kza5w0zykxklkdi5gcfwvgp1mbhw5j8px20624g7bshqa8c0pjk";
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

