{ lib, fetchgit }:

(fetchgit {
  name = "goldendict-dark-theme-2018-11-08";
  url = "https://gist.github.com/ilius/5a2f35c79775267fbdb249493c041453";
  rev = "5c616fa";
  sha256 = "1rpkfcjp3dhdnrnf68id956hvm8bn655cp8v4if5s753vx5ni012";
})
// {
  meta = {
    description = "GoldenDict Dark Theme";
    homepage = "https://gist.github.com/ilius/5a2f35c79775267fbdb249493c041453";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
  };
}
