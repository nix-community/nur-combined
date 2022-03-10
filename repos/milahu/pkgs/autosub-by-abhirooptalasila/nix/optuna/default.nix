{ lib
, buildPythonPackage
, fetchFromGitHub
, pytest
, mock
, bokeh
, plotly
, chainer
, xgboost
, mpi4py
, lightgbm
, keras
, mxnet
, scikit-optimize
, tensorflow # python
, cma
, sqlalchemy
, numpy
, scipy
, six

, cliff
, openstackdocstheme
, dulwich

, colorlog
, pandas
, alembic
, tqdm
, typing
, pythonOlder
, isPy27
, fetchPypi
, callPackage
, pkgs # libtensorflow tensorflow-lite ...
, protobuf
, flatbuffers

, fakeredis
, pytorch # torch
#, fastai # TODO

# fastai
, matplotlib
, fastprogress
, scikit-learn
, pyyaml
, torchvision
#, fastdownload # TODO
#, pandas # dupe
, spacy
, ipywidgets
#, azureml-core # TODO
, azure-core # TODO alias? azureml-core
, ipykernel
, pydicom
, pillow

#, neptune-client # TODO
, websocket-client
, GitPython
, boto3

#, bravado # TODO
, typing-extensions
, msgpack
, simplejson
, python-dateutil
, monotonic
, bravado-core # TODO fix in nixpkgs
#, crochet
, bottle
#, ephemeral_port_reserve
#, fido

# fido
#, yelp-bytes

# crochet
, wrapt
, twisted
, mypy

# bravado-core
, swagger-spec-validator

# fastdownload
, fastcore

# neptune-client
, click
, requests
, oauthlib
, future
, psutil
, pytorch-lightning
, fsspec

, tensorflow-tensorboard # python
#, torchmetrics

, requests_oauthlib

# torchmetrics
, packaging

}:

let
  # nixpkgs/pkgs/top-level/python-packages.nix
  # https://github.com/NixOS/nixpkgs/blob/5ad79dc4bb22326e5a98db7bf2b69a76a2e6f01e/pkgs/development/python-modules/tensorflow/default.nix
  # https://github.com/NixOS/nixpkgs/blob/5ad79dc4bb22326e5a98db7bf2b69a76a2e6f01e/pkgs/development/python-modules/tensorflow/bin.nix
  # https://github.com/NixOS/nixpkgs/blob/5ad79dc4bb22326e5a98db7bf2b69a76a2e6f01e/pkgs/top-level/python-packages.nix
  # https://www.eanalytica.com/blog/Compiling-Tensorflow-to-use-SSE-and-AVX-instructions-on-Nix/
  /*
  tensorflow_slow = tensorflow.override {
    # cat /proc/cpuinfo | grep ^flags | head -n1 | tr ' ' '\n' | grep -i -e sse -e avx -e fma
    avx2Support = false;
    sse42Support = false;
    fmaSupport = false;
    cudaSupport = false;
  };
  */

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/science/math/mxnet/default.nix
  mxnet_slow = callPackage ./mxnet.nix {
    sseSupport = true;
    f16cSupport = false;
    cudaSupport = false;
    inherit (pkgs.linuxPackages) nvidia_x11;
  };

  #azureml = callPackage ./azureml.nix { };

  mxnet_python_slow = mxnet.override {
    pkgs = (pkgs // {
      mxnet = mxnet_slow;
    });
  };
  /* FIXME
  mxnet_python_slow = mxnet.overrideAttrs {
    buildInputs = [ mxnet_slow ];
  };
  */

  #ephemeral_port_reserve = ephemeral-port-reserve; # alias. pip says ephemeral_port_reserve

  bravado = buildPythonPackage rec {
      pname = "bravado";
      version = "11.0.3";
      src = fetchPypi {
        inherit pname version;
        sha256 = "G7bvddhBQMhR//5kILqu5QN9hABwz+EdYJE75quOBTA=";
      };
      nativeBuildInputs = [
        #pkgs.swig
      ];
      propagatedBuildInputs = ([
        #pkgs.alsaLib
        typing-extensions
        pyyaml
        six
        msgpack
        requests
        simplejson
        python-dateutil
        monotonic
        (bravado-core.override {
          inherit jsonschema;
          swagger-spec-validator = swagger-spec-validator.override {
            inherit jsonschema;
          };
        })
      ]);
      checkInputs = [
        crochet
        bottle
        twisted
        ephemeral_port_reserve
        pytest
        wrapt
        fido
      ];
      meta = with lib; {
        homepage = "http://github.com/Yelp/bravado";
        description = "Library for accessing Swagger-enabled API's";
        license = licenses.bsdOriginal;
      };
    };

    Twisted = twisted; # alias. pip says Twisted
    crochet = buildPythonPackage rec {
      pname = "crochet";
      version = "2.0.0";
      src = fetchPypi {
        inherit pname version;
        sha256 = "X39sDUHsQY2hYIDwIC+qxrMPhKb8qdiRHp21Qfjk5SE=";
      };
      nativeBuildInputs = [
        #pkgs.swig
      ];
      propagatedBuildInputs = ([
        #zipp
        wrapt
        Twisted
      ]);
      checkInputs = [
        mypy
      ];
      meta = with lib; {
        homepage = "https://github.com/itamarst/crochet";
        description = "Use Twisted anywhere";
        license = licenses.mit;
      };
    };

    ephemeral_port_reserve = buildPythonPackage rec {
      pname = "ephemeral_port_reserve";
      version = "1.1.4";
      src = fetchPypi {
        inherit pname version;
        sha256 = "uPfaLJcJDLCAGUnewdbUDJciBQW3QqcJNf+9QyNMFLI=";
      };
      nativeBuildInputs = [
        #pkgs.swig
      ];
      propagatedBuildInputs = ([
        #zipp
      ]);
      checkInputs = [
      ];
      meta = with lib; {
        homepage = "https://github.com/Yelp/ephemeral-port-reserve";
        description = "Bind to an ephemeral port, force it into the TIME_WAIT state, and unbind it";
        license = licenses.mit;
      };
    };

    fido = buildPythonPackage rec {
      pname = "fido";
      version = "4.2.2";
      src = fetchPypi {
        inherit pname version;
        sha256 = "b78sF31LYlS3pbI4nORGzuBH6RVc1z+56mbAOGWz5EU=";
      };
      nativeBuildInputs = [
        #pkgs.swig
      ];
      propagatedBuildInputs = ([
        yelp-bytes
        twisted
        crochet
        #zipp
      ]);
      checkInputs = [
      ];
      meta = with lib; {
        homepage = "https://github.com/Yelp/fido";
        description = "Asynchronous HTTP client built on top of Crochet and Twisted";
        license = licenses.asl20; # TODO License: Apache Software License (Copyright Yelp 2014, All Rights Reserved)
      };
    };

    yelp-bytes = yelp_bytes; # alias. pip says yelp-bytes
    yelp_bytes = buildPythonPackage rec {
      pname = "yelp_bytes";
      version = "0.3.0";
      src = fetchPypi {
        inherit pname version;
        sha256 = "MnN7wqHDP96y0dgaY+s3qApbBzqNXYfxePlknuN0E5U=";
      };
      nativeBuildInputs = [
        #pkgs.swig
      ];
      propagatedBuildInputs = ([
        yelp-encodings
        #zipp
      ]);
      checkInputs = [
      ];
      meta = with lib; {
        homepage = "https://github.com/Yelp/yelp_bytes";
        description = "Utilities for dealing with byte strings, invented and maintained by Yelp";
        license = licenses.publicDomain;
      };
    };

    yelp-encodings = yelp_encodings; # alias
    yelp_encodings = buildPythonPackage rec {
      pname = "yelp_encodings";
      version = "1.0.0";
      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-9teiwOltgVRIlOrfQkKEWjxYDMl+j4VnHcXuIhq9qy8=";
      };
      nativeBuildInputs = [
        #pkgs.swig
      ];
      propagatedBuildInputs = ([
        #zipp
      ]);
      checkInputs = [
      ];
      meta = with lib; {
        homepage = "https://github.com/Yelp/yelp_encodings";
        description = "string encodings invented and maintained by yelp";
        license = licenses.publicDomain;
      };
    };

  #bravado-core = callPackage ./nix/bravado-core/default.nix {};
  # jsonschema with uri-template
  # requirement uri-template; extra == "format" (from jsonschema[format])
  jsonschema = callPackage ./nix/jsonschema/default.nix {};

  fastdownload = buildPythonPackage rec {
      pname = "fastdownload";
      version = "0.0.5";
      src = fetchPypi {
        inherit pname version;
        sha256 = "ZOZ68waQ+piuHIobUklXaYQvcjVlI5pUMCCK0FWFrxg=";
      };
      nativeBuildInputs = [
        #pkgs.swig
      ];
      propagatedBuildInputs = ([
        fastprogress
        fastcore
        #zipp
      ]);
      meta = with lib; {
        homepage = "https://github.com/fastai/fastdownload";
        description = "A general purpose data downloading library";
        license = licenses.asl20;
      };
    };

    /*
    requests_oauthlib = requests-oauthlib; # alias
    requests-oauthlib = buildPythonPackage rec {
      pname = "requests-oauthlib";
      version = "1.3.1";
      src = fetchPypi {
        inherit pname version;
        sha256 = "db6sSkeIHuuU1epdatMe+IhWr/4jMrmq+1LGRSzPDXo=";
      };
      nativeBuildInputs = [
      ];
      propagatedBuildInputs = ([
        oauthlib
        requests
      ]);
      checkInputs = [
        requests-mock
        mock
      ];
      doCheck = false;
      # tests require internet access:
      # ERROR: testCanPostBinaryData (tests.test_core.OAuth1Test)
      meta = with lib; {
        homepage = "https://github.com/requests/requests-oauthlib";
        description = "OAuthlib authentication support for Requests";
        license = licenses.isc;
      };
    };
    */

    Pillow = pillow; # alias. pip says Pillow

    /*
    neptune = neptune-client; # alias. import name is neptune. neptune is not taken https://pypi.org/project/neptune/
    neptune-client = buildPythonPackage rec {
      pname = "neptune-client";
      version = "0.14.3";
      src = fetchPypi {
        inherit pname version;
        sha256 = "YOEko0DYzLiEFuPqDIQLWZqg/WEzR+qQPG0NgH1R+9s=";
      };
      nativeBuildInputs = [
      ];
      propagatedBuildInputs = ([
        click
        requests
        oauthlib
        future
        psutil
        requests_oauthlib
        websocket-client
        GitPython
        boto3
        pandas
        Pillow
        bravado
        (pytorch-lightning.overrideAttrs (old: {
          propagatedBuildInputs = [
            future
            pytorch
            pyyaml
            tensorflow-tensorboard
            tqdm
            torchmetrics
            fsspec # fsspec[http]!=2021.06.0,>=2021.05.0
            pyDeprecate
          ];
          preBuild = ''
            sed -i 's/pyDeprecate==0.3.1/pyDeprecate/' requirements.txt
          '';
        }))
        neptune-optuna
      ]);
      meta = with lib; {
        homepage = "https://github.com/neptune-ai/neptune-client";
        description = "Lightweight experiment tracking tool for AI/ML individuals and teams";
        license = licenses.asl20;
      };
    };
    */

    /*
    neptune-optuna = buildPythonPackage rec {
      pname = "neptune-optuna";
      version = "0.9.14";
      src = fetchPypi {
        inherit pname version;
        sha256 = "gjqhTrjsdHTZS5YwjZ/W80ScrBXz/wAFXw5g5EKOfio=";
      };
      nativeBuildInputs = [
      ];
      propagatedBuildInputs = ([
        plotly
        optuna
      ]);
      meta = with lib; {
        homepage = "https://github.com/neptune-ai/neptune-optuna";
        description = "Neptune.ai Optuna integration library";
        license = licenses.asl20;
      };
    };
    */

    torch = pytorch; # alias. pip says torch
    torchmetrics = buildPythonPackage rec {
      pname = "torchmetrics";
      version = "0.7.2";
      src = fetchPypi {
        inherit pname version;
        sha256 = "rwMzTEoz/DKppAsDexzj/2Jz6poAUMEd3eKb8TNdqV4=";
      };
      nativeBuildInputs = [
      ];
      propagatedBuildInputs = ([
        pyDeprecate
        packaging
        pytorch
      ]);
      meta = with lib; {
        homepage = "https://github.com/PyTorchLightning/metrics";
        description = "PyTorch native Metrics";
        license = licenses.asl20;
      };
      doCheck = false;
      # FutureWarning: The `wer` was deprecated since v0.7 in favor of `torchmetrics.functional.text.wer.word_error_rate`. It will be removed in v0.8.
      # TypeError: word_error_rate() missing 2 required positional arguments: 'preds' and 'target'
    };

    pyDeprecate = buildPythonPackage rec {
      pname = "pyDeprecate";
      version = "0.3.2";
      src = fetchPypi {
        inherit pname version;
        sha256 = "1IERbMXX9sRz58S+gg792bkKFrWUs1Anbp5mpstb3Sk=";
      };
      nativeBuildInputs = [
      ];
      propagatedBuildInputs = ([
      ]);
      meta = with lib; {
        homepage = "https://github.com/Borda/pyDeprecate";
        description = "Deprecation tooling";
        license = licenses.mit;
      };
    };


  # TODO cache this in nixpkgs. big package
  fastai = buildPythonPackage rec {
      pname = "fastai";
      version = "2.5.3";
      src = fetchPypi {
        inherit pname version;
        sha256 = "DK5QYXl5sFLw7XM3gA5oFO40a3kiA89IMFcJyTXo7rc=";
      };
      nativeBuildInputs = [
        #pkgs.swig
      ];
      propagatedBuildInputs = ([
        matplotlib
        fastprogress
        scikit-learn
        pyyaml
        torchvision
        fastdownload
        pandas
        fastcore
        spacy
        requests
        pillow
        scipy
        pytorch
        #zipp
      ]);
      # https://github.com/fastai/fastai/blob/master/environment.yml
      /*
      checkInputs = [
        ipywidgets
        neptune
        #azureml.core
        azure-core
        ipykernel
        pydicom
      ];
      */
      doCheck = false; # wontfix? circular dependency: neptune -> optuna -> fastai -> neptune
      meta = with lib; {
        homepage = "https://github.com/fastai/fastai";
        description = "fastai simplifies training fast and accurate neural nets using modern best practices";
        license = licenses.asl20;
      };
    };

  cmaes = buildPythonPackage rec {
    pname = "cmaes";
    version = "0.8.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "HAS6I97ZJe8TuW9Cz71mepBepbgHVMdQ5kSLn82pal0=";
    };
    /*
    src = fetchFromGitHub {
      owner = "CyberAgent";
      repo = pname;
      rev = "v${version}";
      sha256 = "61vVgGILQqVWMZc281/5FW+I/Ny2pGp+Q6Lk6KKazMs=";
    };
    */
    nativeBuildInputs = [
      #pkgs.swig
    ];
    propagatedBuildInputs = ([
      numpy
      #zipp
    ]);
    meta = with lib; {
      homepage = "https://github.com/CyberAgent/cmaes";
      description = "Lightweight Covariance Matrix Adaptation Evolution Strategy (CMA-ES) implementation for Python 3";
      license = licenses.mit;
    };
    #doCheck = false;
  };


in

buildPythonPackage rec {
  pname = "optuna";
  version = "2.10.0";
  disabled = isPy27;

  format = "wheel";
  src = fetchPypi rec {
    inherit pname version format;
    sha256 = "RX/4sStFncHusBeDif+eXE2kF2TMkRUv4yS/1W+I1D8="; # TODO
    dist = python;
    python = "py3";
    #abi = "cp310";
    #platform = "manylinux_2_24_x86_64";
  };

  /*
  src = fetchFromGitHub {
    owner = "optuna";
    repo = pname;
    rev = "v${version}";
    sha256 = "0fha0pwxq6n3mbpvpz3vk8hh61zqncj5cnq063kzfl5d8rd48vcd";
  };
  */

  /*
  checkInputs = [
    pytest
    mock
    bokeh
    plotly
    chainer
    xgboost
    mpi4py
    lightgbm
    keras
    mxnet_python_slow
    #mxnet
    #mxnet_slow # TODO
    scikit-optimize
    tensorflow
    #tensorflow_slow # TODO need this?
    cma
    fakeredis
    pytorch
    fastai
  ];
  */
  doCheck = false; # checks need tensorflow. TODO disable tensorflow tests?

  propagatedBuildInputs = [
    sqlalchemy
    numpy
    scipy
    six
    (cliff.override {
      openstackdocstheme = (openstackdocstheme.override {
        dulwich = (dulwich.override ({
          gpgme = null;
        })).overridePythonAttrs (old: {
          # note: overridePythonAttrs != overrideAttrs
          doCheck = false;
        });
      });
    })
    colorlog
    pandas
    alembic
    tqdm
    cmaes
    packaging
  ] ++ lib.optionals (pythonOlder "3.5") [
    typing
  ];
  /*
  configurePhase = if !(pythonOlder "3.5") then ''
    substituteInPlace setup.py \
      --replace "'typing'," ""
  '' else "";
  */

  /*
  checkPhase = ''
    echo 'checking imports for "illegal instruction"'
    (
      set -x
      python -c 'import tensorflow'
      python -c 'import mxnet'
    )
    pytest --ignore tests/test_cli.py \
           --ignore tests/integration_tests/test_chainermn.py \
           --ignore tests/integration_tests/test_pytorch_lightning.py \
           --ignore tests/integration_tests/test_pytorch_ignite.py \
           --ignore tests/integration_tests/test_fastai.py
  '';
  */

  meta = with lib; {
    # TODO(milahu) fix?
    #broken = true;  # Dashboard broken, other build failures.
    description = "A hyperparameter optimization framework";
    homepage = "https://optuna.org/";
    license = licenses.mit;
    maintainers = [ maintainers.costrouc ];
  };
}
