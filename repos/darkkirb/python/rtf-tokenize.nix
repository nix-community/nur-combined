{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "rtf_tokenize";
  version = "1.0.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-XD3zkNAEeb12N8gjv81v37Id3RuWroFUY95+HtOS1gg=";
  };

  # No tests available
  doCheck = false;

  disabled = pythonOlder "3.6";

  meta = with lib; {
    homepage = "https://github.com/benoit-pierre/rtf_tokenize";
    description = "Simple RTF tokenizer";
    license = licenses.gpl2Plus;
  };
  passthru.updateScript = [../scripts/update-python-libraries "python/rtf-tokenize.nix"];
}
