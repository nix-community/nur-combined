{ stdenv, fetchFromGitHub, python27Packages, nasm, linux, libelf }:
python27Packages.buildPythonApplication rec {
  name = "chipsec-${version}";
  version = "2018-10-23";

  src = fetchFromGitHub {
    owner = "chipsec";
    repo = "chipsec";
    rev = "0b8943cdb8bcb19b66cbe1d3c68108c855eb9134";
    sha256 = "08hnjyvpwn43g5znb0b24hrnqhnw9bwfyhq0cjj12wyicmx67ja0";
  };

  buildInputs = [
    nasm libelf
  ];

  KERNEL_SRC_DIR = "${linux.dev}/lib/modules/${linux.version}/build";

  meta = with stdenv.lib; {
    description = "Platform Security Assessment Framework";
    license = licenses.gpl2;
    homepage = https://github.com/chipsec/chipsec;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
