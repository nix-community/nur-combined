{ stdenv, buildGo111Module, fetchFromGitHub }:

buildGo111Module rec {
  name = "swm-${version}";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "kalbasit";
    repo = "swm";
    rev = "v${version}";
    sha256 = "1x5i53y25mmnl8g3zq4bygv9lfcpc5fp49k0na1l35damvs2wi75";
  };

  modSha256 = "0s63vms3yc5ppn6b48dkgxi40k5q2snhy79381zwgn2k7sr8h5vi";

  meta = with stdenv.lib; {
    homepage = "https://github.com/kalbasit/swm";
    description = "swm (Story-based Workflow Manager) is a Tmux session manager specifically designed for Story-based development workflow";
    license = licenses.mit;
    maintainers = [ maintainers.kalbasit ];
    platforms = platforms.all;
  };
}
