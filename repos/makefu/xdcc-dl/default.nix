# generated using pypi2nix tool (version: 1.8.0)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -V 3.6 -r ./lol
#

{ pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python36;
  };

  commonBuildInputs = [];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreter = pythonPackages.buildPythonPackage {
        name = "python36-interpreter";
        buildInputs = [ makeWrapper ] ++ (builtins.attrValues pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter}               $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "               (builtins.attrValues pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -f $prog ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };
    in {
      __old = pythonPackages;
      inherit interpreter;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (drv.drvAttrs // f drv.drvAttrs);
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {
    inherit (pythonPackages) requests irc beautifulsoup4 six pyqt5;
    "PyExecJS" = python.mkDerivation {
      name = "PyExecJS-1.5.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/1c/a0/359e179605bbf3f6c6ed96c44e056eebed39732b67427f30d56e259934f2/PyExecJS-1.5.0.tar.gz"; sha256 = "99315766f8155eea195a3f4179b35cd8dc64b2360c081ae29d92c603c26aeaaa"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Run JavaScript code from Python";
      };
    };




    "bs4" = python.mkDerivation {
      name = "bs4-0.0.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/10/ed/7e8b97591f6f456174139ec089c769f89a94a1a4025fe967691de971f314/bs4-0.0.1.tar.gz"; sha256 = "36ecea1fd7cc5c0c6e4a1ff075df26d50da647b75376626cc186e2212886dd3a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."beautifulsoup4"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Screen-scraping library";
      };
    };



    "certifi" = python.mkDerivation {
      name = "certifi-2017.11.5";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/23/3f/8be01c50ed24a4bd6b8da799839066ce0288f66f5e11f0367323467f0cbc/certifi-2017.11.5.tar.gz"; sha256 = "5ec74291ca1136b40f0379e1128ff80e866597e4e2c1e755739a913bbc3613c0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "MPL-2.0";
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };



    "cfscrape" = python.mkDerivation {
      name = "cfscrape-1.9.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/cf/9a/50d3844d67fe5507217fd47c9e382e769ab5f7d967b41c25ba3712c441c3/cfscrape-1.9.1.tar.gz"; sha256 = "9cee3708c643904eaa010a64dd1715890457bb77010d87405fc1bfeb892508d7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyExecJS"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "";
        description = "A simple Python module to bypass Cloudflare's anti-bot page. See https://github.com/Anorov/cloudflare-scrape for more information.";
      };
    };



    "typing" = python.mkDerivation {
      name = "typing-3.6.2";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/ca/38/16ba8d542e609997fdcd0214628421c971f8c395084085354b11ff4ac9c3/typing-3.6.2.tar.gz"; sha256 = "d514bd84b284dd3e844f0305ac07511f097e325171f6cc4a20878d11ad771849"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.psfl;
        description = "Type Hints for Python";
      };
    };




    "urwid" = python.mkDerivation {
      name = "urwid-1.3.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/85/5d/9317d75b7488c335b86bd9559ca03a2a023ed3413d0e8bfe18bea76f24be/urwid-1.3.1.tar.gz"; sha256 = "cfcec03e36de25a1073e2e35c2c7b0cc6969b85745715c3a025a31d9786896a1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.lgpl2;
        description = "A full-featured console (xterm et al.) user interface library";
      };
    };



    "xdcc-dl" = python.mkDerivation {
      name = "xdcc-dl-2.1.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/52/5a/1f1c8e77c212074d508701f208440bdfac4c6366de3f74fc9772a09369ef/xdcc_dl-2.1.0.tar.gz"; sha256 = "7071fca28de83ab0944b086a6dac0af053225b5663d9cf28a8dac868d81b2fc6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."bs4"
      self."cfscrape"
      self."irc"
      self."requests"
      self."typing"
      self."urwid"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.gpl3;
        description = "An XDCC File Downloader based on the irclib framework";
      };
    };

  };

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            []
         )
   )
