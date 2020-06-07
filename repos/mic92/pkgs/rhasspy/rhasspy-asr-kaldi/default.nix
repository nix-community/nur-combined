{ lib
, buildPythonPackage
, fetchPypi
, networkx
, rhasspy-asr
, rhasspy-nlu
, pythonOlder
, fetchpatch
}:

buildPythonPackage rec {
  pname = "rhasspy-asr-kaldi";
  version = "0.1.6";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "40a890520acdfab5b82232b41f667d8fa2260d25feae2cb12d1f911e699fce7a";
  };

  propagatedBuildInputs = [
    networkx
    rhasspy-asr
    rhasspy-nlu
  ];

  patches = [
    (fetchpatch {
      url = "https://github.com/rhasspy/rhasspy-asr-kaldi/commit/c54aff91a854d49a8638c69959bc89187c3a48e1.patch";
      sha256 = "1q19d24b5bq8k2l3612f7ad9nv4ck3wihm0d6mhn9k8dwq9xx31g";
    })
  ];

  # misses files
  doCheck = false;

  meta = with lib; {
    description = "Speech to text library for Rhasspy using Kaldi";
    homepage = "https://github.com/rhasspy/rhasspy-asr-kaldi";
    license = licenses.mit;
    maintainers = [ maintainers.mic92 ];
  };
}
