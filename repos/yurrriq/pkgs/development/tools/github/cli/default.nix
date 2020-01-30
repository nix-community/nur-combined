{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "github-cli";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "cli";
    repo = "cli";
    rev = "v${version}";
    sha256 = "0x35zg6lj7xxdrj7s73szl4zg9i8fwafq4kwym2vi3bssnl0fp8m";
  };

  goPackagePath = "github.com/cli/cli";

  modSha256 = "0ina3m2ixkkz2fws6ifwy34pmp6kn5s3j7w40alz6vmybn2smy1h";

  buildPhase = ''
    make -e bin/gh LDFLAGS='-X github.com/cli/cli/command.Version=${version}'
  '';

  installPhase = ''
    install -m755 -d "$out"/bin
    install -m755 bin/gh "$_"
  '';

  meta = with stdenv.lib; {
    description = "the GitHub CLI";
    homepage = "https://cli.github.io/cli/gh";
    license = licenses.mit;
    maintainers = with maintainers; [ yurrriq ];
  };
}
