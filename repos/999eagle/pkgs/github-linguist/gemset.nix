{
  cgi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18zc1z8va9j1gcv131p605wmkvn1p5958mmvvy7v45ki8c0w7qn5";
      type = "gem";
    };
    version = "0.3.6";
  };
  charlock_holmes = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hybw8jw9ryvz5zrki3gc9r88jqy373m6v46ynxsdzv1ysiyr40p";
      type = "gem";
    };
    version = "0.7.7";
  };
  github-linguist = {
    dependencies = ["cgi" "charlock_holmes" "mini_mime" "rugged"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04mj3qbsf97jcdhi9kg48hf4i9hnla83wij763nzcmgmlm3z8a45";
      type = "gem";
    };
    version = "7.24.1";
  };
  mini_mime = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lbim375gw2dk6383qirz13hgdmxlan0vc5da2l072j3qw6fqjm5";
      type = "gem";
    };
    version = "1.1.2";
  };
  rugged = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wnfgxx59nq2wpvi8ll7bqw9x99x5hps6i38xdjrwbb5a3896d58";
      type = "gem";
    };
    version = "1.5.1";
  };
}
