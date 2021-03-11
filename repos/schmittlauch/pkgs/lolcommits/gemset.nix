{
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fvchp2rhp2rmigx7qglf69xvjqvzq7x0g49naliw29r2bz656sy";
      type = "gem";
    };
    version = "2.7.0";
  };
  git = {
    dependencies = ["rchardet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vdcv93s33d9914a9nxrn2y2qv15xk7jx94007cmalp159l08cnl";
      type = "gem";
    };
    version = "1.8.1";
  };
  launchy = {
    dependencies = ["addressable"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xdyvr5j0gjj7b10kgvh8ylxnwk3wx19my42wqn9h82r4p246hlm";
      type = "gem";
    };
    version = "2.5.0";
  };
  lolcommits = {
    dependencies = ["git" "launchy" "lolcommits-loltext" "mercurial-ruby" "methadone" "mini_magick" "open4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qhh8qq5bf2qqkkiqvb90pvmw6q1whaxjkqb49v65dlj3hmvv75i";
      type = "gem";
    };
    version = "0.16.3";
  };
  lolcommits-loltext = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g1bpki6j8hzn22wh68m1gs881r4cis0vccxx1an3zq51hrrk2rf";
      type = "gem";
    };
    version = "0.4.0";
  };
  mercurial-ruby = {
    dependencies = ["open4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "188zlrifrrlr88ls06f2mlji3ww9sm9rcfggfpraw547q4d44icj";
      type = "gem";
    };
    version = "0.7.12";
  };
  methadone = {
    dependencies = [];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dwhlljmrv9r857jv1wnp963hmfnldjdvyqg0mwi8rsibnc30fj8";
      type = "gem";
    };
    version = "1.9.5";
  };
  mini_magick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aj604x11d9pksbljh0l38f70b558rhdgji1s9i763hiagvvx2hs";
      type = "gem";
    };
    version = "4.11.0";
  };
  open4 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cgls3f9dlrpil846q0w7h66vsc33jqn84nql4gcqkk221rh7px1";
      type = "gem";
    };
    version = "1.3.4";
  };
  public_suffix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xqcgkl7bwws1qrlnmxgh8g4g9m10vg60bhlw40fplninb3ng6d9";
      type = "gem";
    };
    version = "4.0.6";
  };
  rchardet = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1isj1b3ywgg2m1vdlnr41lpvpm3dbyarf1lla4dfibfmad9csfk9";
      type = "gem";
    };
    version = "1.8.0";
  };
}