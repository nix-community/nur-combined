{
  pkgs,
  python3,
}:
python3.pkgs.buildPythonPackage {
  pname = "xontrib-zoxide";
  version = "1.0.0";
  src = pkgs.fetchFromGitHub {
    owner = "dyuri";
    repo = "xontrib-zoxide";
    rev = "8140376cb9f3a2ea019982f9837cc427a157ecd9";
    sha256 = "sha256-9xAR2R7IwGttv84qVb+8TkW6OAK6OGLW3o/tDQnUwII=";
  };

  pyproject = true;

  doCheck = false;

  nativeBuildInputs = with pkgs.python3Packages; [
    setuptools
    wheel
    poetry-core
  ];

  postPatch = ''
    sed -ie "/xonsh.*=/d" pyproject.toml
    sed -ie "s@os.path.join(script_path,_cache_name)@os.path.join(os.environ.get('HOME'), '.cache', _cache_name)@" xontrib/zoxide/zoxide.py
  '';

  meta = {
    homepage = "https://github.com/dyuri/xontrib-zoxide";
    license = "MIT";
    description = "[how-to use in nix](https://github.com/drmikecrowe/nur-packages) [how-to](https://github.com/drmikecrowe/nur-packages) xonsh zoxide xontrib";
  };
}
