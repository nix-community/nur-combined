{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "lazycwl";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "myuron";
    repo = "lazycwl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yU5qx1MhhSn37+TBamhzKccPdSLqghhQe0HqlhmEow0=";
  };

  vendorHash = "sha256-71IHdtlB5cjOiYrrr5SJ8d/61ZSuWXGvtra3q1ULFCE=";

  meta = {
    description = "AWS CloudWatch Logs viewer on terminal editor";
    homepage = "https://github.com/myuron/lazycwl";
    license = lib.licenses.mit;
    mainProgram = "lazycwl";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
})
