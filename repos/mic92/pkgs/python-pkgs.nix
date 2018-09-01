{ stdenv, buildPythonPackage, fetchFromGitHub, fetchPypi
, six, ply, nose, flake8, notebook, matplotlib, pip, fetchurl
, isPy36, glibcLocales
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

  frida = buildPythonPackage rec {
    pname = "frida";
    version = "12.1.1";
    disabled = !isPy36;
  
    # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida
  
    src = fetchurl {
      url = "https://dl.thalheim.io/nCVZnxWaZh0VIgEN8O5cdA/frida-${version}-cp36-cp36m-linux_x86_64.whl";
      sha256 = "1d61blq3d10g58l3dhy4b0mr96gp4xswnprjganhqa4nc2g9wqi7";
    };
  
    nativeBuildInputs = [ pip ];
  
    unpackPhase = ":";
  
    format = "other";
  
    installPhase = ''
      cp $src frida-${version}-cp36-cp36m-linux_x86_64.whl
      pip install --prefix=$out frida-${version}-cp36-cp36m-linux_x86_64.whl
    '';
  
    meta = with stdenv.lib; {
      description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
      homepage = https://www.frida.re/;
      license = licenses.wxWindows;
    };
  };
}
