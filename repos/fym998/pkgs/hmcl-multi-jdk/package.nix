{
  hmcl,
}:
hmcl.overrideAttrs (oldAttrs: {
  pname = "hmcl-multi-jdk";
  meta = oldAttrs.meta // {
    description = "HMCL with multiple JDK support (DEPRECATED, use hmcl instead)";
  };
})
