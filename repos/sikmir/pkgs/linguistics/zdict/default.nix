{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "zdict";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "zdict";
    repo = "zdict";
    tag = version;
    hash = "sha256-vZpxJkKBHo9fO7xNN9Is7BumZhAkepVK0dpk+Y/1YBM=";
  };

  dependencies = with python3Packages; [
    beautifulsoup4
    peewee
    requests
  ];

  doCheck = false;

  meta = {
    description = "The last online dictionary framework you need";
    homepage = "https://github.com/zdict/zdict";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
