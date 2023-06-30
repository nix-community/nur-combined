{ lib, appimageTools, fetchurl }:

appimageTools.wrapType2 rec {
  pname = "Sunsama";
  version = "2.0.10";

  src = fetchurl {
    url = "https://desktop.sunsama.com/versions/${version}/linux/appImage/x64";
    sha256 = "sha256-DUtfOkzEFnYUQ7D9dk+3HmB6620P8tbi8YiO6InEudo=";
  };

  meta = with lib; {
    description = "The digital daily planner that helps you feel calm and stay focused";
    homepage = "https://www.sunsama.com/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ sagikazarmark ];
  };
}
