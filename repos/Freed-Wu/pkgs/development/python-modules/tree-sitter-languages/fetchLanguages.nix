# Generated using generateFetchLanguages.sh
fetchFromGitHub:
''
  mkdir -p vendor
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-jsdoc";
    rev = "6a6cf9e7341af32d8e2b2e24a37fbfebefc3dc55";
    sha256 = "1xmkkqyb9mc18jh6dlffzw9j560mmc5i6fbic8ki9z0r30b1ravw";
  }} vendor/tree-sitter-jsdoc
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-julia";
    rev = "e84f10db8eeb8b9807786bfc658808edaa1b4fa2";
    sha256 = "1fqirr8yjwmjy5dnfxk0djafq0hnl18mf28i7zg2gsfvy9a27d4f";
  }} vendor/tree-sitter-julia
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-python";
    rev = "b8a4c64121ba66b460cb878e934e3157ecbfb124";
    sha256 = "12bgdbhkxl7lrca4257wnjks1m4z3mv5mzw5cfbyr91ypv59cfk5";
  }} vendor/tree-sitter-python
  ln -sv ${fetchFromGitHub {
    owner = "Azganoth";
    repo = "tree-sitter-lua";
    rev = "6b02dfd7f07f36c223270e97eb0adf84e15a4cef";
    sha256 = "0h1s5r02wh64mnaag3wpqm2a33pmzag7mal93v1vsfgs5wnrv8ry";
  }} vendor/tree-sitter-lua
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-bash";
    rev = "f3f26f47a126797c011c311cec9d449d855c3eab";
    sha256 = "13mizaf84snksr0hs3fhax4vayb9rrv64qqgr6q0sxisqs3z25z9";
  }} vendor/tree-sitter-bash
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-json";
    rev = "3b129203f4b72d532f58e72c5310c0a7db3b8e6d";
    sha256 = "0rnfhmhr76fjlc6zzbxzrxrxa1xxpkg1jgq7vdw4630l1cg2nlbm";
  }} vendor/tree-sitter-json
  ln -sv ${fetchFromGitHub {
    owner = "WhatsApp";
    repo = "tree-sitter-erlang";
    rev = "54b6f814f43c4eac81eeedefaa7cc8762fec6683";
    sha256 = "134cnzpw1mk7bfrfbqkrd4abd6nb1si7xpbrqkg0m11p70354nnv";
  }} vendor/tree-sitter-erlang
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-ql";
    rev = "ff04ba61857ba05b80221e71b423b2728dbebe1e";
    sha256 = "1wdjy8287823rgl1vibljgf129ll9srxn9n6m1piaj3z46lv5b7x";
  }} vendor/tree-sitter-ql
  ln -sv ${fetchFromGitHub {
    owner = "MichaHoffmann";
    repo = "tree-sitter-hcl";
    rev = "e936d3fef8bac884661472dce71ad82284761eb1";
    sha256 = "1spl8s1slhf25ry3sggbgckgq5aprc4sq76sgzswdb4rmghyrjwm";
  }} vendor/tree-sitter-hcl
  ln -sv ${fetchFromGitHub {
    owner = "alemuller";
    repo = "tree-sitter-make";
    rev = "a4b9187417d6be349ee5fd4b6e77b4172c6827dd";
    sha256 = "07gz4x12xhigar2plr3jgazb2z4f9xp68nscmvy9a7wafak9l2m9";
  }} vendor/tree-sitter-make
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-c";
    rev = "371fd0bf0650581b6e49f06f438c88c419859696";
    sha256 = "0a7y33hwyvsq2kn8il9xz0bcizwq6qai2fzdspjxjfkck5pzi8fd";
  }} vendor/tree-sitter-c
  ln -sv ${fetchFromGitHub {
    owner = "camdencheek";
    repo = "tree-sitter-go-mod";
    rev = "bbe2fe3be4b87e06a613e685250f473d2267f430";
    sha256 = "1clw1wyjxiicdjav5g2b9m9q7vlg5k1iy1fqwmf2yc4fxrfnmyrq";
  }} vendor/tree-sitter-go-mod
  ln -sv ${fetchFromGitHub {
    owner = "r-lib";
    repo = "tree-sitter-r";
    rev = "c55f8b4dfaa32c80ddef6c0ac0e79b05cb0cbf57";
    sha256 = "0si338c05z3bapxkb7zwk30rza5w0saw0jyk0pljxi32869w8s9m";
  }} vendor/tree-sitter-r
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-embedded-template";
    rev = "6d791b897ecda59baa0689a85a9906348a2a6414";
    sha256 = "0d4kc2bpbx1bvd0xv37wd87hbi775hq4938qz2n657h036dzg0i3";
  }} vendor/tree-sitter-embedded-template
  ln -sv ${fetchFromGitHub {
    owner = "elixir-lang";
    repo = "tree-sitter-elixir";
    rev = "511ea5e0088779e4bdd76e12963ab9a5fe99983a";
    sha256 = "06p7y6693fk9qdgpxwjqph2f5hibns46njv832k95qwdys2rnpw0";
  }} vendor/tree-sitter-elixir
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-regex";
    rev = "ba22e4e0cb42b2ef066948d0ea030ac509cef733";
    sha256 = "02nxl4s5vx8nsmhg7cjaf45nl92x8q60b7jhlp29qdqvbgg35gwr";
  }} vendor/tree-sitter-regex
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-go";
    rev = "fd577c4358c28cbcb6748bbf65354cc85f1cf7a4";
    sha256 = "1gwzg90z8m80klqp0n6kn93b46mi8f2k5n3n05bv6bf9515p2gqp";
  }} vendor/tree-sitter-go
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-cpp";
    rev = "e0c1678a78731e78655b7d953efb4daecf58be46";
    sha256 = "0fjxjm3gjqvcjqgjyq6lg6sgyy0ly69dinq33rmy56806da45lq9";
  }} vendor/tree-sitter-cpp
  ln -sv ${fetchFromGitHub {
    owner = "m-novikov";
    repo = "tree-sitter-sql";
    rev = "587f30d184b058450be2a2330878210c5f33b3f9";
    sha256 = "145kz5y65zc8jyjhmsq0vmda5fv6g94xwldkzl10p5hnfnqrg76g";
  }} vendor/tree-sitter-sql
  ln -sv ${fetchFromGitHub {
    owner = "stsewd";
    repo = "tree-sitter-rst";
    rev = "3ba9eb9b5a47aadb1f2356a3cab0dd3d2bd00b4b";
    sha256 = "1yqrc5fwbvpdqx1y4f83f36wwzaplj5q69fhjylcs8fws2d7a3fk";
  }} vendor/tree-sitter-rst
  ln -sv ${fetchFromGitHub {
    owner = "slackhq";
    repo = "tree-sitter-hack";
    rev = "fca1e294f6dce8ec5659233a6a21f5bd0ed5b4f2";
    sha256 = "0a9psxz30lg3z6wybl5yhzlgj17k2yv5xlxzic0b1hg55fl2qdsx";
  }} vendor/tree-sitter-hack
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-ocaml";
    rev = "712d9bfa1d537c5899dde5538767ed2d8bb37a93";
    sha256 = "0w10ib2k0y098kvl9hsxizbfiq853z62pdyfnwdbn9ippn35r24p";
  }} vendor/tree-sitter-ocaml
  ln -sv ${fetchFromGitHub {
    owner = "dhcmrlchtdj";
    repo = "tree-sitter-sqlite";
    rev = "993be0a91c0c90b0cc7799e6ff65922390e2cefe";
    sha256 = "0jhl4i2cvlgf0bvk19b6q4x3w0m48gxzirswl2gcgp2v75c4gx94";
  }} vendor/tree-sitter-sqlite
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-java";
    rev = "5e62fbb519b608dfd856000fdc66536304c414de";
    sha256 = "1pjq3sg0f9id8fwivkzdmbillcr0a2zpf1ckdm1q6q7ksasvwj2s";
  }} vendor/tree-sitter-java
  ln -sv ${fetchFromGitHub {
    owner = "jiyee";
    repo = "tree-sitter-objc";
    rev = "afec0de5a32d5894070b67932d6ff09e4f7c5879";
    sha256 = "1b8gmqhq0fv9waxp8im1xj01yq3mjpq0v0z6dvnvf7r4y7n2y2k7";
  }} vendor/tree-sitter-objc
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-html";
    rev = "b285e25c1ba8729399ce4f15ac5375cf6c3aa5be";
    sha256 = "1vg6g2qd6b2hrzflmc8rlkmslx2xw3haasy1cg2jpdapc6mm40bc";
  }} vendor/tree-sitter-html
  ln -sv ${fetchFromGitHub {
    owner = "ganezdragon";
    repo = "tree-sitter-perl";
    rev = "a882a928d4930716896039d1c10e91b6d7444c48";
    sha256 = "0ss26x37ldj4v6pwbijrz0hbnvj8xrm8cj3y1n1f2xanzvcalz15";
  }} vendor/tree-sitter-perl
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-c-sharp";
    rev = "4b4e82ca0a30376ae605e77a0d8a3c803c9f9327";
    sha256 = "0rwcqcshk419rdl44fxaa7vvf8a2v0cdn247gykg8apjzag7iw9l";
  }} vendor/tree-sitter-c-sharp
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-css";
    rev = "02b4ee757654b7d54fe35352fd8e53a8a4385d42";
    sha256 = "0j1kg16sly7xsvvc3kxyy5zaznlbz7x2j2bwwv1r1nki2249ly12";
  }} vendor/tree-sitter-css
  ln -sv ${fetchFromGitHub {
    owner = "ikatyang";
    repo = "tree-sitter-markdown";
    rev = "8b8b77af0493e26d378135a3e7f5ae25b555b375";
    sha256 = "1a2899x7i6dgbsrf13qzmh133hgfrlvmjsr3bbpffi1ixw1h7azk";
  }} vendor/tree-sitter-markdown
  ln -sv ${fetchFromGitHub {
    owner = "rydesun";
    repo = "tree-sitter-dot";
    rev = "9ab85550c896d8b294d9b9ca1e30698736f08cea";
    sha256 = "013brrljrhgpnks1r0cdvj93l303kb68prm18gpl96pvhjfci063";
  }} vendor/tree-sitter-dot
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-ruby";
    rev = "9d86f3761bb30e8dcc81e754b81d3ce91848477e";
    sha256 = "0qzwgx6hs9bx7wbgyrazsrf6k69fikcddcmqiqxlq2jnjgxyxdr1";
  }} vendor/tree-sitter-ruby
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-typescript";
    rev = "b00b8eb44f0b9f02556da0b1a4e2f71faed7e61b";
    sha256 = "1lv3w5wxpzjbq629b7krnbww2hba6vk4s7y3l8p4jm4kaw9v0sxq";
  }} vendor/tree-sitter-typescript
  ln -sv ${fetchFromGitHub {
    owner = "ikatyang";
    repo = "tree-sitter-yaml";
    rev = "0e36bed171768908f331ff7dff9d956bae016efb";
    sha256 = "0wyvjh62zdp5bhd2y8k7k7x4wz952l55i1c8d94rhffsbbf9763f";
  }} vendor/tree-sitter-yaml
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-tsq";
    rev = "49da6de661be6a07cb51018880ebe680324e7b82";
    sha256 = "1np9li55b28iyg5msmqzkp7ydd887j2nb2fzx3jmzx3ifb533plr";
  }} vendor/tree-sitter-tsq
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-php";
    rev = "ad414fa5497328e96ef992d80896f19c77584f7c";
    sha256 = "1rampjgvlakd7p5jd6ig3sa66fccnkc14x91zfr8c6rpr2s67kla";
  }}/php vendor/tree-sitter-php
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-scala";
    rev = "70b4fe63c4973b04cc7bd40c6b7646d9c2430db8";
    sha256 = "0292znac00blhfjhg2gdn5pvb90sn5b254g17x6546ar349fq2k7";
  }} vendor/tree-sitter-scala
  ln -sv ${fetchFromGitHub {
    owner = "fwcd";
    repo = "tree-sitter-kotlin";
    rev = "260afd9a92bac51b3a4546303103c3d40a430639";
    sha256 = "09pdbmjbq1y2hrlmh7z6hpfw9ssz8kf0ix9d0sm0h0mddhd58svj";
  }} vendor/tree-sitter-kotlin
  ln -sv ${fetchFromGitHub {
    owner = "Wilfred";
    repo = "tree-sitter-elisp";
    rev = "e5524fdccf8c22fc726474a910e4ade976dfc7bb";
    sha256 = "1wyzfb27zgpvm4110jgv0sl598mxv5dkrg2cwjw3p9g2bq9mav5d";
  }} vendor/tree-sitter-elisp
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-rust";
    rev = "3a56481f8d13b6874a28752502a58520b9139dc7";
    sha256 = "12806974pngxqv1brj4r15yqzp2fdvid926n7941nylgmdw9f4z9";
  }} vendor/tree-sitter-rust
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-haskell";
    rev = "6b5ec205c9d4f23eb36a163f1edc4f2db8c98e4a";
    sha256 = "1d3klbflb1xl234s6pw874j1d5r82bkx5jdi7il1irfvhgdkjljc";
  }} vendor/tree-sitter-haskell
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-javascript";
    rev = "de1e682289a417354df5b4437a3e4f92e0722a0f";
    sha256 = "1mvvc6cv46zyhxhdjycmj7746hbss7lxcxks61bzrh229nlrh6hy";
  }} vendor/tree-sitter-javascript
  ln -sv ${fetchFromGitHub {
    owner = "stadelmanma";
    repo = "tree-sitter-fortran";
    rev = "f73d473e3530862dee7cbb38520f28824e7804f6";
    sha256 = "1nvxdrzkzs1hz0fki5g7a2h7did66jghaknfakqn92fa20pagl1b";
  }} vendor/tree-sitter-fortran
  ln -sv ${fetchFromGitHub {
    owner = "camdencheek";
    repo = "tree-sitter-dockerfile";
    rev = "33e22c33bcdbfc33d42806ee84cfd0b1248cc392";
    sha256 = "1zhrg9ick72m1ywvnvab8kw4a2ncfsxl2hkrnckx0by96r6v68mq";
  }} vendor/tree-sitter-dockerfile
  ln -sv ${fetchFromGitHub {
    owner = "elm-tooling";
    repo = "tree-sitter-elm";
    rev = "09dbf221d7491dc8d8839616b27c21b9c025c457";
    sha256 = "1s5675l6bv8kabghclrj3rzbhxc5psh391s8ayrc40l4v9daib86";
  }} vendor/tree-sitter-elm
  ln -sv ${fetchFromGitHub {
    owner = "ZedThree";
    repo = "tree-sitter-fixed-form-fortran";
    rev = "e80ef5afc04b6845db778d05025f2a1b76969ad9";
    sha256 = "0gzk6grl2p3717gmhz84ip7sqfy16bb29fqg71sy9qwg264qs3f4";
  }} vendor/tree-sitter-fixed-form-fortran
  ln -sv ${fetchFromGitHub {
    owner = "theHamsta";
    repo = "tree-sitter-commonlisp";
    rev = "cf10fc38bc24faf0549d59217ff37c789973dfdc";
    sha256 = "1nq5cvf557w3vwr7rjzdgqcpcs3ikp1x5cs00f8z5n9hgdk1lvry";
  }} vendor/tree-sitter-commonlisp
  ln -sv ${fetchFromGitHub {
    owner = "tree-sitter";
    repo = "tree-sitter-toml";
    rev = "342d9be207c2dba869b9967124c679b5e6fd0ebe";
    sha256 = "00pigsc947qc2p6g21iki6xy4h497arq53fp2fjgiw50bqmknrsp";
  }} vendor/tree-sitter-toml
  python build.py
''
