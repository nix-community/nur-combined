{ callPackage }:
{
  spring-assistant = callPackage
    ({ ideaBuild }: ideaBuild {
      pname = "intellij-spring-assistant";
      version = "0.12.0";
      pluginId = 10229;
      versionId = 44968;
      sha256 = "13cglywzhb4j0qj0bs2jwaz2k8pxrxalv35wgkmgkxr635bxmwsj";
    })
    { };
}
