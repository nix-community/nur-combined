# Generated using generateFetchLanguages.sh
fetchFromGitHub:
''
  mkdir -p vendor
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-ql";
    rev = "bd087020f0d8c183080ca615d38de0ec827aeeaf";
    sha256 = "18yv6sag794k0l7i0wxaffxhay6zgwnap5bbhi48h04q1cvas0yr";
  }} vendor/tree-sitter-ql
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-julia";
    rev = "0c088d1ad270f02c4e84189247ac7001e86fe342";
    sha256 = "16l2flg1pzfcqd02k05y90ydmnki5vzp2m9rf2j2afr8slnawjaq";
  }} vendor/tree-sitter-julia
  ln -sv ${fetchFromGitHub {
    owner = "alemuller";
    repo = "tree-sitter-make";
    rev = "a4b9187417d6be349ee5fd4b6e77b4172c6827dd";
    sha256 = "07gz4x12xhigar2plr3jgazb2z4f9xp68nscmvy9a7wafak9l2m9";
  }} vendor/tree-sitter-make
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-c-sharp";
    rev = "dd5e59721a5f8dae34604060833902b882023aaf";
    sha256 = "15rdg846pnaad6fpljf0bhwxa4jc9vmlnma55a8jpp5p9hiccn8f";
  }} vendor/tree-sitter-c-sharp
  ln -sv ${fetchFromGitHub {
    owner = "ikatyang";
    repo = "tree-sitter-markdown";
    rev = "8b8b77af0493e26d378135a3e7f5ae25b555b375";
    sha256 = "1a2899x7i6dgbsrf13qzmh133hgfrlvmjsr3bbpffi1ixw1h7azk";
  }} vendor/tree-sitter-markdown
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-python";
    rev = "4bfdd9033a2225cc95032ce77066b7aeca9e2efc";
    sha256 = "0gcxmydhb7r6n01nd3a36qrdqrli13qdmixk3d726jvrrxmp2ww5";
  }} vendor/tree-sitter-python
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-ruby";
    rev = "4d9ad3f010fdc47a8433adcf9ae30c8eb8475ae7";
    sha256 = "07rqmk893760idpwaslmdppgsl1mhq5wl3igpg53061akzwlsykp";
  }} vendor/tree-sitter-ruby
  ln -sv ${fetchFromGitHub {
    owner = "r-lib";
    repo = "tree-sitter-r";
    rev = "c55f8b4dfaa32c80ddef6c0ac0e79b05cb0cbf57";
    sha256 = "0si338c05z3bapxkb7zwk30rza5w0saw0jyk0pljxi32869w8s9m";
  }} vendor/tree-sitter-r
  ln -sv ${fetchFromGitHub {
    owner = "camdencheek";
    repo = "tree-sitter-dockerfile";
    rev = "25c71d6a24cdba8f0c74ef40d4d2d93defd7e196";
    sha256 = "1kljz139ppngp0gmgvvw73w03220pjk60fsz6kz53j5bf8anz933";
  }} vendor/tree-sitter-dockerfile
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-css";
    rev = "98c7b3dceb24f1ee17f1322f3947e55638251c37";
    sha256 = "18pnknsigb61z84iab76vsnmqzsvqvirvlvv5lk49pybmlk00zgv";
  }} vendor/tree-sitter-css
  ln -sv ${fetchFromGitHub {
    owner = "fwcd";
    repo = "tree-sitter-kotlin";
    rev = "0ef87892401bb01c84b40916e1f150197bc134b1";
    sha256 = "008cwkwy3ha44nzdgc11nbvwkcxpywjp2is9wl6bkwlpnnqji3q3";
  }} vendor/tree-sitter-kotlin
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-go";
    rev = "ff86c7f1734873c8c4874ca4dd95603695686d7a";
    sha256 = "13af7js4a8dhs4bcc63n1sm53kb9lsmk335mb9qxy7pshyjw11fj";
  }} vendor/tree-sitter-go
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-toml";
    rev = "342d9be207c2dba869b9967124c679b5e6fd0ebe";
    sha256 = "00pigsc947qc2p6g21iki6xy4h497arq53fp2fjgiw50bqmknrsp";
  }} vendor/tree-sitter-toml
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-ocaml";
    rev = "4abfdc1c7af2c6c77a370aee974627be1c285b3b";
    sha256 = "1kq96mkg5m79y13r3z0529q70kkyn5qdrkv33sam9cgblwha7jf9";
  }} vendor/tree-sitter-ocaml
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-regex";
    rev = "2354482d7e2e8f8ff33c1ef6c8aa5690410fbc96";
    sha256 = "1b5sbjzdhkvpqaq2jsb347mrspjzmif9sqmvs82mp2g08bmr122z";
  }} vendor/tree-sitter-regex
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-html";
    rev = "949b78051835564bca937565241e5e337d838502";
    sha256 = "139vkwg7pcc4m2iphz7gz6aaflnhwk1i9zxb6wx3h4rya8vqacwy";
  }} vendor/tree-sitter-html
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-javascript";
    rev = "f1e5a09b8d02f8209a68249c93f0ad647b228e6e";
    sha256 = "0jslqjlmfx0xdgwhqam0lgw22r521iynp8l10pfan2bmqxmbdcjm";
  }} vendor/tree-sitter-javascript
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-rust";
    rev = "e0e8b6de6e4aa354749c794f5f36a906dcccda74";
    sha256 = "128jxg6sc2v49bm64mkjn0q09bgpdnbyhkgfjwdqcvk2x43g213s";
  }} vendor/tree-sitter-rust
  ln -sv ${fetchFromGitHub {
    owner = "theHamsta";
    repo = "tree-sitter-commonlisp";
    rev = "c7e814975ab0d0d04333d1f32391c41180c58919";
    sha256 = "1hq3pwrp8509scgn983g0mi8pjy2q21pms30xlc3q7yyjxvpsw7b";
  }} vendor/tree-sitter-commonlisp
  ln -sv ${fetchFromGitHub {
    owner = "elixir-lang";
    repo = "tree-sitter-elixir";
    rev = "11426c5fd20eef360d5ecaf10729191f6bc5d715";
    sha256 = "1fqsvqdjscmjj7vaq3mgs6j49m3412g5i9jrm1r61n1d8yrg3mzy";
  }} vendor/tree-sitter-elixir
  ln -sv ${fetchFromGitHub {
    owner = "stadelmanma";
    repo = "tree-sitter-fortran";
    rev = "f73d473e3530862dee7cbb38520f28824e7804f6";
    sha256 = "1nvxdrzkzs1hz0fki5g7a2h7did66jghaknfakqn92fa20pagl1b";
  }} vendor/tree-sitter-fortran
  ln -sv ${fetchFromGitHub {
    owner = "elm-tooling";
    repo = "tree-sitter-elm";
    rev = "c26afd7f2316f689410a1622f1780eff054994b1";
    sha256 = "1cbn5qiq2n607hcxg786jrhs2abln8fcsvkcab9wp9j8iw9pb0xx";
  }} vendor/tree-sitter-elm
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-tsq";
    rev = "b665659d3238e6036e22ed0e24935e60efb39415";
    sha256 = "03bch2wp2jwxk69zjplvm0gbyw06qqdy7il9qkiafvhrbh03ayd9";
  }} vendor/tree-sitter-tsq
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-typescript";
    rev = "d847898fec3fe596798c9fda55cb8c05a799001a";
    sha256 = "1bklkigyhsqxmy38nf3f1kj18zzp1im3qlkj3hi3nnsxjsfckjxb";
  }} vendor/tree-sitter-typescript
  ln -sv ${fetchFromGitHub {
    owner = "dhcmrlchtdj";
    repo = "tree-sitter-sqlite";
    rev = "993be0a91c0c90b0cc7799e6ff65922390e2cefe";
    sha256 = "0jhl4i2cvlgf0bvk19b6q4x3w0m48gxzirswl2gcgp2v75c4gx94";
  }} vendor/tree-sitter-sqlite
  ln -sv ${fetchFromGitHub {
    owner = "stsewd";
    repo = "tree-sitter-rst";
    rev = "3ba9eb9b5a47aadb1f2356a3cab0dd3d2bd00b4b";
    sha256 = "1yqrc5fwbvpdqx1y4f83f36wwzaplj5q69fhjylcs8fws2d7a3fk";
  }} vendor/tree-sitter-rst
  ln -sv ${fetchFromGitHub {
    owner = "rydesun";
    repo = "tree-sitter-dot";
    rev = "917230743aa10f45a408fea2ddb54bbbf5fbe7b7";
    sha256 = "1q2rbv16dihlmrbxlpn0x03na7xp8rdhf58vwm3lryn3nfcjckn2";
  }} vendor/tree-sitter-dot
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-php";
    rev = "33e30169e6f9bb29845c80afaa62a4a87f23f6d6";
    sha256 = "1mywp2i51jvq9j1amhanw50w3wncv3q1g04b7gwyf29gx36kwff4";
  }} vendor/tree-sitter-php
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-cpp";
    rev = "a71474021410973b29bfe99440d57bcd750246b1";
    sha256 = "083gz4vn56qnc6cvs73d2a3pilvknvnk5kkwjkk22c8l5bq3id2j";
  }} vendor/tree-sitter-cpp
  ln -sv ${fetchFromGitHub {
    owner = "ganezdragon";
    repo = "tree-sitter-perl";
    rev = "15a6914b9b891974c888ba7bf6c432665b920a3f";
    sha256 = "177j7215b1wqyws70cpmrr0w8j9bj11nk4yc6pqrai2rr5vm9vx1";
  }} vendor/tree-sitter-perl
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-embedded-template";
    rev = "203f7bd3c1bbfbd98fc19add4b8fcb213c059205";
    sha256 = "0gf33p08a6hqbxwy9zlp8y65gds2d6siqpgasc58ladh5p5n99j9";
  }} vendor/tree-sitter-embedded-template
  ln -sv ${fetchFromGitHub {
    owner = "ikatyang";
    repo = "tree-sitter-yaml";
    rev = "0e36bed171768908f331ff7dff9d956bae016efb";
    sha256 = "0wyvjh62zdp5bhd2y8k7k7x4wz952l55i1c8d94rhffsbbf9763f";
  }} vendor/tree-sitter-yaml
  ln -sv ${fetchFromGitHub {
    owner = "slackhq";
    repo = "tree-sitter-hack";
    rev = "fca1e294f6dce8ec5659233a6a21f5bd0ed5b4f2";
    sha256 = "0a9psxz30lg3z6wybl5yhzlgj17k2yv5xlxzic0b1hg55fl2qdsx";
  }} vendor/tree-sitter-hack
  ln -sv ${fetchFromGitHub {
    owner = "Azganoth";
    repo = "tree-sitter-lua";
    rev = "6b02dfd7f07f36c223270e97eb0adf84e15a4cef";
    sha256 = "0h1s5r02wh64mnaag3wpqm2a33pmzag7mal93v1vsfgs5wnrv8ry";
  }} vendor/tree-sitter-lua
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-scala";
    rev = "45b5ba0e749a8477a8fd2666f082f352859bdc3c";
    sha256 = "0fwfjpmbf0wc9dirrwdf09pqfs1y4768gkl75z1m2sc2d5694zdl";
  }} vendor/tree-sitter-scala
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-json";
    rev = "3fef30de8aee74600f25ec2e319b62a1a870d51e";
    sha256 = "02h218snijaxjb538s719hqma5sdi680bj73yw8i4g3knavxrj9j";
  }} vendor/tree-sitter-json
  ln -sv ${fetchFromGitHub {
    owner = "MichaHoffmann";
    repo = "tree-sitter-hcl";
    rev = "e135399cb31b95fac0760b094556d1d5ce84acf0";
    sha256 = "154shms17gk83gql463hgb0f3z436idhjhhl8mr6hq5xwy7njp32";
  }} vendor/tree-sitter-hcl
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-java";
    rev = "2b57cd9541f9fd3a89207d054ce8fbe72657c444";
    sha256 = "1jhgmgiig5vxz8x961qdp9d3xwawgi5lwsfs1i7d53ffli1qm3v6";
  }} vendor/tree-sitter-java
  ln -sv ${fetchFromGitHub {
    owner = "camdencheek";
    repo = "tree-sitter-go-mod";
    rev = "4a65743dbc2bb3094114dd2b43da03c820aa5234";
    sha256 = "1hblbi2bs4hlil703myqhvvq2y1x41rc3w903hg2bhbazh7x8yyf";
  }} vendor/tree-sitter-go-mod
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-c";
    rev = "34f4c7e751f4d661be3e23682fe2631d6615141d";
    sha256 = "0hvi8kc2j43kwcgsb2hmm350kq9w8dj6zg3iwivmnslhsz9dx92n";
  }} vendor/tree-sitter-c
  ln -sv ${fetchFromGitHub {
    owner = "WhatsApp";
    repo = "tree-sitter-erlang";
    rev = "54b6f814f43c4eac81eeedefaa7cc8762fec6683";
    sha256 = "134cnzpw1mk7bfrfbqkrd4abd6nb1si7xpbrqkg0m11p70354nnv";
  }} vendor/tree-sitter-erlang
  ln -sv ${fetchFromGitHub {
    owner = "Wilfred";
    repo = "tree-sitter-elisp";
    rev = "4b0e4a3891337514126ec72c7af394c0ff2cf48c";
    sha256 = "1g6qmpxn1y9hzk2kkpp9gpkphaq9j7vvm4nl5zv8a4wzy3w8p1wv";
  }} vendor/tree-sitter-elisp
  ln -sv ${fetchFromGitHub {
    owner = "jiyee";
    repo = "tree-sitter-objc";
    rev = "afec0de5a32d5894070b67932d6ff09e4f7c5879";
    sha256 = "1b8gmqhq0fv9waxp8im1xj01yq3mjpq0v0z6dvnvf7r4y7n2y2k7";
  }} vendor/tree-sitter-objc
  ln -sv ${fetchFromGitHub {
    owner = "ZedThree";
    repo = "tree-sitter-fixed-form-fortran";
    rev = "3142d317c73de80882beb95cc431af7eb6c28c51";
    sha256 = "1dz9zf5nacsqdab3cv821a320kmal999y1f3x03yky59k9nx8dp2";
  }} vendor/tree-sitter-fixed-form-fortran
  ln -sv ${fetchFromGitHub {
    owner = "m-novikov";
    repo = "tree-sitter-sql";
    rev = "218b672499729ef71e4d66a949e4a1614488aeaa";
    sha256 = "1j68h5jzc0d3a44v5mw005lh3zsrh0salfzydl9br1n8byl1awms";
  }} vendor/tree-sitter-sql
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-haskell";
    rev = "dd924b8df1eb76261f009e149fc6f3291c5081c2";
    sha256 = "1ckbv7ypxjsvxnb8whr1r24q5qmmp97zhx003hdyx63rhrx48vxf";
  }} vendor/tree-sitter-haskell
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-bash";
    rev = "f7239f638d3dc16762563a9027faeee518ce1bd9";
    sha256 = "1v1gf0hya615q4ymjiyl03yjb845jsgdryimx5vbjh3j86rn9jpq";
  }} vendor/tree-sitter-bash
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-jsdoc";
    rev = "d01984de49927c979b46ea5c01b78c8ddd79baf9";
    sha256 = "11w3a6jfvf8fq1jg90bsnhj89gvx32kv1gy4gb5y32spx6h87f1v";
  }} vendor/tree-sitter-jsdoc
  python build.py
''
