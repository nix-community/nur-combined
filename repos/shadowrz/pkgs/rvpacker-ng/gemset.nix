{
  formatador = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mprf1dwznz5ld0q1jpbyl59fwnwk6azspnd0am7zz7kfg3pxhv5";
      type = "gem";
    };
    version = "0.3.0";
  };
  optimist = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vg2chy1cfmdj6c1gryl8zvjhhmb3plwgyh1jfnpq4fnfqv7asrk";
      type = "gem";
    };
    version = "3.0.1";
  };
  psych = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10iawnkpa44hcfrapy7yw6zmjn4g1g0y09lw244qiv424f7jasn5";
      type = "gem";
    };
    version = "3.3.2";
  };
  rvpacker-ng = {
    dependencies = ["formatador" "optimist" "psych" "scanf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a594zl454grjw7f5dp0x3v6gkxh5wnz2m5bpmq1qp65smldsvmp";
      type = "gem";
    };
    version = "1.3.2";
  };
  scanf = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "000vxsci3zq8m1wl7mmppj7sarznrqlm6v2x2hdfmbxcwpvvfgak";
      type = "gem";
    };
    version = "1.0.0";
  };
}
