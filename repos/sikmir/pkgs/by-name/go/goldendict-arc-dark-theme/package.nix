{ lib, fetchgit }:

(fetchgit {
  name = "goldendict-arc-dark-theme-2020-04-06";
  url = "https://gist.github.com/ManiaciaChao/ddb14a09a12c95f134003bcd552dced4";
  rev = "af58374";
  sha256 = "0z3rsi87bf6mlb9syqvsz1jg74i3mxf2cxq43jlfr9zkdmnwgj18";
})
// {
  meta = {
    description = "GoldenDict Arc Dark Theme";
    homepage = "https://gist.github.com/ManiaciaChao/ddb14a09a12c95f134003bcd552dced4";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
}
