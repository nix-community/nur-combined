{ lib
, fetchFromGitHub
, buildPythonApplication
, telethon
, jinja2
, pyyaml # PyYAML
, cryptg
, pillow # Pillow
, feedgen
, python-magic
, setuptools # pkg_resources
, pytz
}:

buildPythonApplication rec {
  pname = "tg-archive";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "knadh";
    repo = "tg-archive";
    rev = "v${version}";
    hash = "sha256-/b9LmHOyFqaKiQ5FHemLmg6DZU+3zzh1jLBEI7RTu4Q=";
  };
  # relax dependencies
  postPatch = ''
    sed -i 's/==/>=/' requirements.txt
  '';
  propagatedBuildInputs = [
    #python-telegram-bot # gi
    telethon
    jinja2
    pyyaml # PyYAML
    cryptg
    pillow # Pillow
    feedgen
    python-magic
    setuptools # pkg_resources
    pytz
  ];
  meta = with lib; {
    homepage = "https://github.com/knadh/tg-archive";
    description = "export Telegram group chats into static websites to preserve chat history like mailing list archives";
    #maintainers = [];
    license = licenses.mit;
    #platforms = platforms.linux;
  };
}
