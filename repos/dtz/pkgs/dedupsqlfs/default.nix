{ python3, lib, fetchFromGitHub, pkgs }:

python3.pkgs.buildPythonApplication rec {
  pname = "dedupsqlfs";
  version = "1.2.938";

  src = fetchFromGitHub {
    owner = "sergey-dryabzhinsky";
    repo = pname;
    rev = "v${version}";
    sha256 = "1sjq5ilrfp4jhjqlpyl5wmnw3zswd3a3mc86wcs6vc2lbi41q997";
  };

  doCheck = false; # revisit

  propagatedBuildInputs = 
    (with pkgs; [ brotli lzo snappy lz4 xz fuse3 sqlite mysql ])
    ++
    (with python3.pkgs; [ pymysql llfuse cython ]);


  patches = [ ./install.patch ];

  postInstall = ''
    find $out -name "__pycache__" -type d -depth -exec rm -rf {} \;
  '';
}
