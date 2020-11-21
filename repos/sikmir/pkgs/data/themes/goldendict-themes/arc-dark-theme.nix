{ lib, fetchgit }:

(fetchgit {
  name = "goldendict-arc-dark-theme-2019-04-06";
  url = "https://gist.github.com/ManiaciaChao/ddb14a09a12c95f134003bcd552dced4";
  rev = "af58374";
  sha256 = "0z3rsi87bf6mlb9syqvsz1jg74i3mxf2cxq43jlfr9zkdmnwgj18";
}) // {
  meta = with lib; {
    description = "GoldenDict Arc Dark Theme";
    homepage = "https://gist.github.com/ManiaciaChao/ddb14a09a12c95f134003bcd552dced4";
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
  };
}
