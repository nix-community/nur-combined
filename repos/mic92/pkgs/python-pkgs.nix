{ stdenv, buildPythonPackage, fetchFromGitHub, fetchPypi
, six, ply, nose, flake8, notebook, matplotlib
, glibcLocales
}:

rec {
  pry = buildPythonPackage rec {
    pname = "pry.py";
    version = "0.1.1";
  
    src = fetchPypi {
      inherit pname version;
      sha256 = "1lwxq9aq6iphsl5mhq543n9dv1z75g609vwgi0b3krd5b31laa06";
    };
  
    meta = with stdenv.lib; {
      description = "An interactive drop in shell for python, similar to binding.pry in ruby";
      homepage = https://github.com/Mic92/pry.py;
      license = licenses.mit;
    };
  };

  lesscpy = buildPythonPackage rec {
    pname = "lesscpy";
    version = "0.13.0";
    propagatedBuildInputs = [ six ply ];
    checkInputs = [ nose flake8 glibcLocales ];
    src = fetchFromGitHub {
      owner = "lesscpy";
      repo = "lesscpy";
      rev = version;
      sha256 = "1jf5bp4ncvw2gahhkvjy5b0366y9x3ki9r9c5n6hkvifjk3jhmb2";
    };
    LC_ALL = "en_US.utf8";
    meta = with stdenv.lib; {
      description = "Python LESS Compiler";
      homepage = https://github.com/lesscpy/lesscpy;
      license = licenses.mit;
    };
  };

  jupyterthemes = buildPythonPackage rec {
    pname = "jupyterthemes";
    version = "0.19.6";
    propagatedBuildInputs = [ notebook matplotlib lesscpy ];
    src = fetchPypi {
      inherit pname version;
      sha256 = "14ypp2i3q7dkhndh55yqygk1fkiz2gryk6vn6w3flyc3ynpfmjfp";
    };

    meta = with stdenv.lib; {
      description = "Custom Jupyter Notebook Themes";
      homepage = https://github.com/dunovank/jupyter-themes;
      license = licenses.mit;
    };
  };
}
