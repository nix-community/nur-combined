{ stdenv, buildGoModule, fetchzip }:
let
  repo = "https://git.sr.ht/~priegger/go-hello-world";
  rev = "285f4d4526d2f64bd8e0f06bfaecfeeb4c3b19d8";
in
buildGoModule {
  name = "go-hello-world";

  src = fetchzip {
    url = "${repo}/archive/${rev}.tar.gz";
    sha256 = "0ikjcv903hw43nzs4lvarynjh1s8xh9xxv472b5hsrxr5nz1r2ln";
  };

  modSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";

  meta = with stdenv.lib; {
    description = "Hello World in Go";
    homepage = repo;
    license = licenses.mit;
  };
}
