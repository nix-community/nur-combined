{
  lib,
  flutter338,
  fetchFromGitHub,
}:

flutter338.buildFlutterApplication rec {
  pname = "rain";
  version = "1.3.9";

  src = fetchFromGitHub {
    owner = "darkmoonight";
    repo = "Rain";
    tag = "v${version}";
    hash = "sha256-w8bDsb7SfXfnf8Ie1axpW5A+DpwlNendDsbUYoMqHTk=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  meta = {
    description = "Weather application";
    homepage = "https://github.com/darkmoonight/Rain";
    license = lib.licenses.mit;
    mainProgram = "rain";
    platforms = lib.platforms.linux;
  };
}
