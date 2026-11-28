{
  openjdk25,
  stdenv,
  addSettings,
}:

addSettings openjdk25 (finalAttrs: ''
  ISABELLE_JAVA_PLATFORM=${stdenv.hostPlatform.system}
  ISABELLE_JDK_HOME=${finalAttrs.finalPackage}
'')
