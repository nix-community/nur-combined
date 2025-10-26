{ coredns }:

coredns.override {
  externalPlugins = [
    {
      name = "meship";
      repo = "github.com/zhoreeq/coredns-meship";
      version = "ba2685d1803672262638f752edb0ae97932b58fa";
    }
    {
      name = "meshname";
      repo = "github.com/zhoreeq/coredns-meshname";
      version = "a3eb6c946497242b3d5aa73e979a62444299dde2";
    }
  ];
  vendorHash = "sha256-0CXCIERq2vvC+bqLjkv+QssltkHu0fKSDrAwH4npaCg=";
}
