{ lib, pythonPackages, git
, enableOlm ? !pythonPackages.python.stdenv.isDarwin
}:

with pythonPackages;

buildPythonPackage rec {
  pname = "nio";
  version = "0.17.0";

  src = fetchPypi {
    pname = "matrix-nio";
    inherit version;
    sha256 = "18dpf8hpn279yxd0i8rk51lcl3qa94dlxqw2xbryq31px57d49mq";
  };

  postPatch = lib.optionalString (!enableOlm) ''
    substituteInPlace setup.py \
      --replace 'python-olm>=3.1.0' ""
  '';

  doCheck = enableOlm;

  propagatedBuildInputs = let
    aiohttp-socks = pythonPackages.aiohttp-socks.overrideAttrs (old: rec {
      version = "0.5.5";
      src = fetchPypi {
        inherit version;
        pname = "aiohttp_socks";
        sha256 = "0jmhb0l1w8k1nishij3awd9zv8zbyb5l35a2pdalrqxxasbhbcif";
      };

      propagatedBuildInputs = old.propagatedBuildInputs ++ [ pythonPackages.python-socks ];
    });
    aiofiles = pythonPackages.aiofiles.overrideAttrs (old: rec {
      version = "0.4.0";
      src = fetchPypi {
        inherit (old) pname;
        inherit version;
        sha256 = "1vmvq9qja3wahv8m1adkyk00zm7j0x64pk3f2ry051ja66xa07h2";
      };
    });
    hpack = pythonPackages.hpack.overrideAttrs (old: rec {
      version = "3.0.0";
      src = fetchPypi {
        inherit (old) pname;
        inherit version;
        sha256 = "1lp9ja4dk6jg0pm2d18kvh95k9p6yxhh4l1h7y541qzs9cgrrv4f";
      };
    });
    hyperframe = pythonPackages.hyperframe.overrideAttrs (old: rec {
      version = "5.2.0";
      src = fetchPypi {
        inherit (old) pname;
        inherit version;
        sha256 = "07xlf44l1cw0ghxx46sbmkgzil8vqv8kxwy42ywikiy35izw3xd9";
      };
    });
    h2 = (pythonPackages.h2.override { inherit hpack hyperframe; }).overrideAttrs (old: rec {
      version = "3.2.0";
      src = fetchPypi {
        inherit (old) pname;
        inherit version;
        sha256 = "051gg30aca26rdxsmr9svwqm06pdz9bv21ch4n0lgi7jsvml2pw7";
      };
    });
    h11 = pythonPackages.h11.overrideAttrs (old: rec {
      version = "0.9.0";
      src = fetchPypi {
        inherit (old) pname;
        inherit version;
        sha256 = "1qfad70h59hya21vrzz8dqyyaiqhac0anl2dx3s3k80gpskvrm1k";
      };
    });
  in with pythonPackages; [
    attrs
    future
    h11
    h2
    pycryptodome
    sphinx
    Logbook
    jsonschema
    unpaddedbase64
  ] ++ lib.optionals (!pythonPackages.python.isPy2) [ aiohttp aiofiles aiohttp-socks ]
    ++ lib.optionals enableOlm [ olm peewee atomicwrites cachetools ];

  passthru = {
    inherit enableOlm;
  };
}
