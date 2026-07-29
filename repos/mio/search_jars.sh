#!/bin/sh
DIR="/nix/store/c5idwxcjycvzmi9kkjh3wdqcbk2c50lw-jps-bootstrap-262.8665.259/share/java/jps-bootstrap-classpath"
for jar in $DIR/*.jar; do
    if unzip -l "$jar" 2>/dev/null | grep -q "org/jetbrains/kotlin/config/JVMConfigurationKeys.class"; then
        echo "Found in: $jar"
        javap -cp "$jar" org.jetbrains.kotlin.config.JVMConfigurationKeys | grep -o "IGNORED_ANNOTATIONS_FOR_BRIDGES" || echo "  -> MISSING!"
    fi
done
