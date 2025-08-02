{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "fuck-u-code";
  version = "1.0.0-beta.1";

  src = fetchFromGitHub {
    owner = "Done-0";
    repo = finalAttrs.pname;
    rev = "d7961972012153b3c5c386be26290c0af949a419";
    hash = "sha256-omvq19u4qewLzvRnrr87osFG+AwU8S4ACMGXuIA16CQ=";
  };

  vendorHash = "sha256-ZG6QPokhGj19okGo44+elJlWpGRrbfBnzi/Y/UykQTY=";

  meta = {
    description = "屎山代码检测器，评估代码的“屎山等级”，并输出美观的终端报告。";
    license = lib.licenses.mit;
    homepage = "https://github.com/Done-0/fuck-u-code";
    mainProgram = "fuck-u-code";
  };
})
