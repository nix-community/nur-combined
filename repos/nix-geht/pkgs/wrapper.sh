#!@runtimeShell@

set -- @mainClass@ "$@"
@extraSetup@
@pkcs11Setup@

# OCF merges its configuration key by key (first definition wins) from
# $JAVA_HOME/lib/opencard.properties, $HOME/.opencard.properties,
# ./opencard.properties and ./.opencard.properties. The loader class set
# below additionally falls back to the packaged defaults in
# @out@/share/scsh3/opencard.properties for any key not defined there.
exec @java@ \
  -Dsun.security.smartcardio.t1GetResponse=false \
  -Dorg.bouncycastle.asn1.allow_unsafe_integer=true \
  -DOpenCard.loaderClassName=org.nixos.scsh3.DefaultConfigurationLoader \
  "-Dsun.security.smartcardio.library=@pcscLibrary@" \
  "-Dscsh3.exepath=@out@/share/scsh3" \
  "-Djava.library.path=@out@/share/scsh3/lib" \
  -classpath "@out@/share/scsh3:@out@/share/scsh3/lib/*" \
  "$@"
