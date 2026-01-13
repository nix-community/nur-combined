{
  lib,
  buildGoModule,
  sources,
  source ? sources.new-api,

  new-api-frontend,
}:

buildGoModule (finalAttrs: {
  pname = "new-api";
  inherit (source) src version;

  vendorHash = "sha256-qsbEiIRjlmcygpHT0qiIdWXCIe+HZ/L8bDWM8dM7VPc=";

  postPatch = ''
    cp -r ${new-api-frontend} web/dist
  '';

  ldflags = [
    "-s"
    "-X new-api/common.Version=v${finalAttrs.version}"
  ];

  # nix-update auto

  meta = {
    description = "Next-generation LLM gateway and AI asset management system supports multiple languages";
    longDescription = ''
      AI模型聚合管理中转分发系统，一个应用管理您的所有AI模型，
      支持将多种大模型转为统一格式调用，支持OpenAI、Claude、Gemini等格式，
      可供个人或者企业内部管理与分发渠道使用。

      🍥 The next-generation LLM gateway and AI asset management system supports multiple languages
    '';
    homepage = "https://github.com/QuantumNous/new-api";
    license = {
      fullName = "New API Usage-Based Dual License (AGPLv3 with branding restrictions)";
      shortName = "New-API-License";
      url = "https://github.com/QuantumNous/new-api/blob/main/LICENSE";
      free = false;
      redistributable = true;
    };
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "new-api";
    platforms = lib.attrNames new-api-frontend.nodeModulesHashes;
  };
})
