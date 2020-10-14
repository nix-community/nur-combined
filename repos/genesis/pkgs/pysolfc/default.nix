{ stdenv, fetchzip, myPython3Packages, python3Packages
, freecell-solver }:

python3Packages.buildPythonApplication rec {
  pname = "PySolFC";
  version = "2.10.1";

  src = fetchzip {
    url = "https://versaweb.dl.sourceforge.net/project/pysolfc/PySolFC/PySolFC-${version}/PySolFC-${version}.tar.xz";
    sha256 = "0d4fs885v7qj8fbf1fskx3ffjr92w8hvixbnqw529fh36khc3319";
  };

  cardsets = fetchzip {
    url = "https://versaweb.dl.sourceforge.net/project/pysolfc/PySolFC-Cardsets/PySolFC-Cardsets-2.0/PySolFC-Cardsets-2.0.tar.bz2";
    sha256 = "0h0fibjv47j8lkc1bwnlbbvrx2nr3l2hzv717kcgagwhc7v2mrqh";
  };

  postPatch = ''
    sed -i s:/usr/share/PySolFC:$out/share/PySolFC: pysollib/settings.py
  '';

  dontUseSetuptoolsCheck = true;

  propagatedBuildInputs = with python3Packages; [
    attrs configobj six random2
    myPython3Packages.pysol_cards
    myPython3Packages.pycotap
    tkinter
    #  optional :
    pygame freecell-solver pillow
  ];

  postInstall = ''
    mkdir $out/share/PySolFC/cardsets
    cp -r $cardsets/* $out/share/PySolFC/cardsets
  '';

  meta = with stdenv.lib; {
    description = "A collection of more than 1000 solitaire card games";
    homepage = https://pysolfc.sourceforge.io;
    license = licenses.gpl3;
    maintainers = with maintainers; [ kierdavis genesis ];
  };
}
