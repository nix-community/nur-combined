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
      sha256 = "1xilhw56xcl3ymf4dnka6w9cxhmj39nxahj8ksazd245vnrpdkdy";
      type = "gem";
    };
    version = "7.25.0";
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
      sha256 = "016bawsahkhxx7p8azxirpl7y2y7i8a027pj8910gwf6ipg329in";
      type = "gem";
    };
    version = "1.6.3";
  };
}
