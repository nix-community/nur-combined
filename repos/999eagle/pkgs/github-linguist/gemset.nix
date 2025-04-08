{
  cgi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rj7agrnd1a4282vg13qkpwky0379svdb2z2lc0wl8588q6ikjx3";
      type = "gem";
    };
    version = "0.4.2";
  };
  charlock_holmes = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1c1dws56r7p8y363dhyikg7205z59a3bn4amnv2y488rrq8qm7ml";
      type = "gem";
    };
    version = "0.7.9";
  };
  github-linguist = {
    dependencies = ["cgi" "charlock_holmes" "mini_mime" "rugged"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nsmsaficl96wzdibjj245n29p4hk1hqzy1n84q6j5d29pjinqpc";
      type = "gem";
    };
    version = "9.1.0";
  };
  mini_mime = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vycif7pjzkr29mfk4dlqv3disc5dn0va04lkwajlpr1wkibg0c6";
      type = "gem";
    };
    version = "1.1.5";
  };
  rugged = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b7gcf6pxg4x607bica68dbz22b4kch33yi0ils6x3c8ql9akakz";
      type = "gem";
    };
    version = "1.9.0";
  };
}
