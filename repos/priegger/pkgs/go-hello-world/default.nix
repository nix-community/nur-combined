{ lib, buildGoModule, fetchFromSourcehut }:

buildGoModule {
  name = "go-hello-world";
  preferLocalBuild = true;

  src = fetchFromSourcehut {
    owner = "~priegger";
    repo = "go-hello-world";
    rev = "174829b602d15a6d1b3cb05cd7698222bd91dfd0";
    hash = "sha256:1zisg7i3a0hj18nq9i0633zmkkapl1xpdc6s8fwhynw5fjbp7hbj";
  };

  vendorSha256 = null;

  meta = with lib; {
    description = "A go hello world application";
    homepage = "https://git.sr.ht/~priegger/go-hello-world";
    license = licenses.mit;
    maintainers = [ maintainers.priegger ];
  };
}
