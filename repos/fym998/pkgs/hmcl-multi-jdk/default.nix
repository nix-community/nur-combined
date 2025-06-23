{
  hmcl,
}:
hmcl.overrideAttrs (oldAttrs: {
  pname = "hmcl-multi-jdk";
  meta = oldAttrs.meta // {
    broken = true;
    description = "HMCL with multiple JDK support (deprecated)";
  };
})
