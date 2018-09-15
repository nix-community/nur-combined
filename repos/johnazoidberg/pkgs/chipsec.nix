{ stdenv, fetchFromGitHub, python27Packages, nasm, linux, libelf }:
python27Packages.buildPythonApplication {
  name = "chipsec";

  src = fetchFromGitHub {
    owner = "chipsec";
    repo = "chipsec";

    rev = "dc4ee91bb6bac804d412082417045ff3747c0f27";
    sha256 = "12jfxkb5njbczivgrsgrwrhcia7alilqfsa86cmypzvx7d0l4vf6";
  };

  buildInputs = [
    nasm libelf
  ];

  KERNEL_SRC_DIR = "${linux.dev}/lib/modules/4.14.59/build";

  meta = with stdenv.lib; {
    description = "";
    license = licenses.gpl2;
    homepage = https://github.com/chipsec/chipsec;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
