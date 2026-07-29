# Downgrade Kotlin JVM target to 24 (since Nixpkgs Kotlin 2.2.20 doesn't support 25)
find . -type f -name "*.iml" -exec sed -i 's/arg="25"/arg="24"/g' {} +
find . -type f -name "*.iml" -exec sed -i 's/JVM 25/JVM 24/g' {} +
find . -type f -name "*.iml" -exec sed -i 's/JVM \[25\]/JVM \[24\]/g' {} +

find . -type f -name "*.xml" -exec sed -i 's/jvmTarget="25"/jvmTarget="24"/g' {} +
find . -type f -name "*.xml" -exec sed -i 's/value="25"/value="24"/g' {} +

sed -i 's/<arg value="25"\/>/<arg value="24"\/>/g' platform/jps-bootstrap/jps-bootstrap-classpath.xml

# Workaround for Kotlin 2.2.20 compiler crash on 0.toUShort()
find platform/eel -name "EelProxyImpl.kt" -exec sed -i 's/acceptorPort == 0\.toUShort()/acceptorPort\.toInt() == 0/g' {} +
# Workaround for Kotlin compiler exhaustiveness check bug
find platform/eel-nioFs -name "EelPathTransfer.kt" -exec sed -i 's/is DiffOperation.ReplaceFile -> diffOp.sourceFile/is DiffOperation.ReplaceFile -> diffOp.sourceFile\n                  else -> error("unreachable")/g' {} +
# Workaround Kotlin 2.2.20 visibility exposure error
sed -i 's/^final class ContextCallable/public final class ContextCallable/g' platform/util/src/com/intellij/util/concurrency/ContextCallable.java
sed -i "s/internal fun currentJavaVersionPlatformSpecific(): JavaVersion = linkToActual()/internal fun currentJavaVersionPlatformSpecific(): JavaVersion = DefaultJavaVersion/g" platform/util/multiplatform/src/com/intellij/util/JavaVersionShim.kt
# Fix compose compiler plugin path
COMPOSE_JAR=$(grep "MAVEN_REPOSITORY.*/compose-compiler-plugin-for-ide.*\.jar!" .idea/libraries/kotlinc_compose_compiler_plugin.xml | head -n 1 | sed -n 's|.*\$MAVEN_REPOSITORY\$/\(.*\)!/.*|\1|p')
COMPOSE_JAR_PATH="$PWD/../.m2/repository/$COMPOSE_JAR"
find . -type f -name "*.iml" -exec sed -i "s|\\\$KOTLIN_COMPOSE_COMPILER_PLUGIN\\\$|$COMPOSE_JAR_PATH|g" {} +
# Fix EelReadFileImpl.kt compiler crash
find platform/eel-impl-base -name "EelReadFileImpl.kt" -exec sed -i 's/Int.MAX_VALUE.toUInt()/2147483647U/g' {} +

# Export kotlinx.collections.immutable from intellij.platform.core to fix java compilation errors in downstream modules
# Kotlin 2.4.20-dev adds type annotations that cause javac to try resolving PersistentSet/PersistentList from core APIs.
sed -i 's/<orderEntry type="module" module-name="intellij.libraries.kotlinx.collections.immutable" \/>/<orderEntry type="module" module-name="intellij.libraries.kotlinx.collections.immutable" exported="" \/>/g' \
  platform/core-api/intellij.platform.core.iml

# Export caffeine from intellij.python.sdk to fix java compilation error in intellij.python.community.testFramework
sed -i 's/<orderEntry type="module" module-name="intellij.libraries.caffeine" \/>/<orderEntry type="module" module-name="intellij.libraries.caffeine" exported="" \/>/g' \
  python/python-sdk/intellij.python.sdk.iml

# Suppress DEPRECATION_ERROR in ClassNameCalculator.kt which causes Kotlin 2.4 compiler to fail
sed -i 's/package org.jetbrains.kotlin.idea.debugger.base.util/@file:Suppress("DEPRECATION_ERROR")\n\npackage org.jetbrains.kotlin.idea.debugger.base.util/g' \
  plugins/kotlin/jvm-debugger/base/util/src/org/jetbrains/kotlin/idea/debugger/base/util/ClassNameCalculator.kt

# Export intellij.platform.ide.core from intellij.platform.externalSystem.impl to fix java compilation error in intellij.gradle.java.maven
sed -i 's/<orderEntry type="module" module-name="intellij.platform.ide.core" \/>/<orderEntry type="module" module-name="intellij.platform.ide.core" exported="" \/>/g' \
  platform/external-system-impl/intellij.platform.externalSystem.impl.iml
# Fix java.lang.NoClassDefFoundError: fleet/util/multiplatform/ExpectInMultiplatformKt during listBundledPlugins
sed -i 's/<orderEntry type="module" module-name="fleet.util.multiplatform" scope="PROVIDED" \/>/<orderEntry type="module" module-name="fleet.util.multiplatform" \/>/g' \
  fleet/multiplatform.shims/fleet.multiplatform.shims.iml

# Fix GradleModelControllerImpl.kt compiler error
find plugins/gradle/tooling-extension-impl -name "GradleModelControllerImpl.kt" -exec sed -i 's/modelParameter\.parameterClass, modelParameter\.parameterInitializer/modelParameter.parameterClass as Class<Any>, modelParameter.parameterInitializer as Action<in Any>/g' {} +
# Fix GlyphViewFix.kt compiler error (sun.swing.text.GlyphViewAccessor is inaccessible/removed in JDK 24+)
cat << 'EOF' > platform/util/ui/src/com/intellij/util/ui/html/GlyphViewFix.kt
package com.intellij.util.ui.html
internal object GlyphViewFix {
  fun init() {}
}
EOF
# Fix coroutineDumper.kt: kotlinx.coroutines.debug.internal.SUSPENDED is no longer accessible
# in Kotlin 2.4.20-dev (internal/private in file). Replace import with inline string literal.
sed -i 's|import kotlinx.coroutines.debug.internal.SUSPENDED||' \
  platform/util/base/src/com/intellij/diagnostic/coroutineDumper.kt
sed -i 's|info\.state == SUSPENDED|info.state == "SUSPENDED"|g' \
  platform/util/base/src/com/intellij/diagnostic/coroutineDumper.kt
# Update kotlinc.xml KotlinJpsPluginSettings version to match the JPS plugin jar we provide.
# KotlinBinaries.loadKotlinJpsPluginToClassPath validates loaded version == required version.
sed -i 's|value="2\.4\.0"|value="2.4.20-dev-6724"|g' .idea/kotlinc.xml
# Also update the sha256sum in kotlinc_kotlin_jps_plugin_classpath.xml:
# our sed updates the version (2.3.20 -> 2.4.20-dev-6724) but the sha256 was for 2.3.20.
# The 2.4.20-dev-6724 jar's actual SHA256 is ecce173... (verified from intellij-deps maven repo).
sed -i 's|0d6103ec6a0eb9c36e856c04d3478099ab86437dd5f19a22a69d9e80b4cff2cb|ecce173028d70a046238b8881b72544a66737a2fac6e8f1caf32de8efc585fbc|g' \
  .idea/libraries/kotlinc_kotlin_jps_plugin_classpath.xml
# Also update the sha256sum for kotlinc_kotlin_jps_plugin_tests.xml
sed -i 's|fb351eeb8e11fae3096c43241611f686e8d1940d0f3b6ba6befe71ef908426ce|12192a1db3fc2f452b7aaa458fe8e7f92121d78fe19ba3741d557276a46206b6|g' \
  .idea/libraries/kotlinc_kotlin_jps_plugin_tests.xml
# Also update the sha256sum for kotlinc_kotlin_dist.xml
sed -i 's|74eabb16163c4575b5dc4b2038268026f389849200f466870714342ccc3792d3|4279120a4bf9b7ae4cd060290e3df30d0776f5b29395f0f68a780357c8cb2fc7|g' \
  .idea/libraries/kotlinc_kotlin_dist.xml

# Upgrade Kotlin version in IDE libraries to match 2.4.20-dev-6724
find . -type f -name "*.xml" -exec sed -i 's/kotlin-dist-for-ide:2.3.20/kotlin-dist-for-ide:2.4.20-dev-6724/g' {} +
find . -type f -name "*.xml" -exec sed -i 's/kotlin-dist-for-ide\/2.3.20/kotlin-dist-for-ide\/2.4.20-dev-6724/g' {} +
find . -type f -name "*.xml" -exec sed -i 's/kotlin-dist-for-ide-2.3.20/kotlin-dist-for-ide-2.4.20-dev-6724/g' {} +

find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-classpath:2.3.20/kotlin-jps-plugin-classpath:2.4.20-dev-6724/g' {} +
find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-classpath\/2.3.20/kotlin-jps-plugin-classpath\/2.4.20-dev-6724/g' {} +
find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-classpath-2.3.20/kotlin-jps-plugin-classpath-2.4.20-dev-6724/g' {} +

find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-tests-for-ide:2.3.20/kotlin-jps-plugin-tests-for-ide:2.4.20-dev-6724/g' {} +
find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-tests-for-ide\/2.3.20/kotlin-jps-plugin-tests-for-ide\/2.4.20-dev-6724/g' {} +
find . -type f -name "*.xml" -exec sed -i 's/kotlin-jps-plugin-tests-for-ide-2.3.20/kotlin-jps-plugin-tests-for-ide-2.4.20-dev-6724/g' {} +

# The KOTLIN_PATH_HERE/JPS_PLUGIN_CLASSPATH_HERE substitutions below are overridden by
# the outer build's postPatch and buildPhase (builtins.replaceStrings), so these sed calls
# are effectively no-ops but kept for reference.
unzip -q ../.m2/repository/org/jetbrains/kotlin/kotlin-dist-for-ide/2.4.20-dev-6724/kotlin-dist-for-ide-2.4.20-dev-6724.jar -d ../kotlin-dist-for-ide-2.4.20-dev-6724 2>/dev/null || true
find . -type f -name "KotlinCompilerDependencyDownloader.kt" -exec sed -i "s|KOTLIN_PATH_HERE|$PWD/../kotlin-dist-for-ide-2.4.20-dev-6724|g" {} +
find . -type f -name "KotlinCompilerDependencyDownloader.kt" -exec sed -i "s|JPS_PLUGIN_CLASSPATH_HERE|$PWD/../.m2/repository/org/jetbrains/kotlin/kotlin-jps-plugin-classpath/2.4.20-dev-6724/kotlin-jps-plugin-classpath-2.4.20-dev-6724.jar|g" {} +

# Bypass expects compiler plugin manually with robust sed commands
sed -i 's/.*fun <K, V> MultiplatformConcurrentHashMap().*/fun <K, V> MultiplatformConcurrentHashMap(): MultiplatformConcurrentHashMap<K, V> = MultiplatformConcurrentHashMapJvm()/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/MultiplatformConcurrentHashMap.kt
sed -i 's/.*fun <T> MultiplatformConcurrentHashSet().*/fun <T> MultiplatformConcurrentHashSet(): MultiplatformConcurrentHashSet<T> = MultiplatformConcurrentHashSetJvm()/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/MultiplatformConcurrentHashSet.kt
sed -i 's/.*fun threadLocalImpl.*/internal fun threadLocalImpl(supplier: () -> Any?): ThreadLocal<Any?> = threadLocalImplJvm(supplier)/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/ThreadLocal.kt
sed -i 's/internal inline fun synchronizedImplJvm/inline fun synchronizedImplJvm/g' fleet/multiplatform.shims/srcJvmMain/fleet/multiplatform/shims/Synchronized.jvm.kt
sed -i '/fun synchronizedImpl/ s/.*/inline fun synchronizedImpl(lock: SynchronizedObject, block: () -> Any?): Any? = synchronizedImplJvm(lock, block)/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/Synchronized.kt
sed -i '/fun SynchronizedObject()/ s/.*/fun SynchronizedObject(): SynchronizedObject = SynchronizedObjectJvm()/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/Synchronized.kt
sed -i '/fun currentThreadId/ s/.*/fun currentThreadId(): Long = currentThreadIdJvm()/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/CurrentThread.kt
sed -i '/fun currentThreadName/ s/.*/fun currentThreadName(): String = currentThreadNameJvm()/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/CurrentThread.kt
sed -i 's/.*fun DispatchersIO().*/internal fun DispatchersIO(): CoroutineDispatcher = DispatchersIOJvm()/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/DispatchersIO.kt
sed -i 's/.*fun runInterruptibleImpl.*/suspend fun runInterruptibleImpl(context: CoroutineContext, block: () -> Any?): Any? = runInterruptibleImplJvm(context, block)/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/RunInterruptible.kt
sed -i 's/= linkToActual()/= newSingleThreadCoroutineDispatcherJvm(name, priority)/' fleet/multiplatform.shims/srcCommonMain/fleet/multiplatform/shims/SingleThreadCoroutineDispatcher.kt
sed -i 's/.*fun getLoggerFactory().*/internal fun getLoggerFactory(): KLoggerFactory = getLoggerFactoryJvm()/' fleet/util/logging/api/srcCommonMain/fleet/util/logging/KLoggers.kt
sed -i '/fun String.capitalizeWithCurrentLocale/ s/.*/fun String.capitalizeWithCurrentLocale(): String = capitalizeWithCurrentLocaleJvm()/' fleet/util/core/srcCommonMain/fleet/util/String.kt
sed -i '/fun String.lowercaseWithCurrentLocale/ s/.*/fun String.lowercaseWithCurrentLocale(): String = lowercaseWithCurrentLocaleJvm()/' fleet/util/core/srcCommonMain/fleet/util/String.kt
sed -i '/fun String.uppercaseWithCurrentLocale/ s/.*/fun String.uppercaseWithCurrentLocale(): String = uppercaseWithCurrentLocaleJvm()/' fleet/util/core/srcCommonMain/fleet/util/String.kt
sed -i '/fun String.isValidUriString/ s/.*/fun String.isValidUriString(): Boolean = isValidUriStringJvm()/' fleet/util/core/srcCommonMain/fleet/util/String.kt
sed -i '/fun getName()/ s/.*/internal fun getName(): String = getNameJvm()/' fleet/util/core/srcCommonMain/fleet/util/Os.kt
sed -i '/fun getVersion()/ s/.*/internal fun getVersion(): String = getVersionJvm()/' fleet/util/core/srcCommonMain/fleet/util/Os.kt
sed -i '/fun getArch()/ s/.*/internal fun getArch(): String = getArchJvm()/' fleet/util/core/srcCommonMain/fleet/util/Os.kt
sed -i '/fun codepointsToString/ s/.*/internal fun codepointsToString(vararg codepoints: Int): String = codepointsToStringJvm(*codepoints)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun codepointOf/ s/.*/internal fun codepointOf(highSurrogate: Char, lowSurrogate: Char): Codepoint = codepointOfJvm(highSurrogate, lowSurrogate)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun highSurrogate/ s/.*/internal fun highSurrogate(codepoint: Int): Char = highSurrogateJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun lowSurrogate/ s/.*/internal fun lowSurrogate(codepoint: Int): Char = lowSurrogateJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isLetter(/ s/.*/internal fun isLetter(codepoint: Int): Boolean = isLetterJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isDigit(/ s/.*/internal fun isDigit(codepoint: Int): Boolean = isDigitJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isLetterOrDigit(/ s/.*/internal fun isLetterOrDigit(codepoint: Int): Boolean = isLetterOrDigitJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isUpperCase(/ s/.*/internal fun isUpperCase(codepoint: Int): Boolean = isUpperCaseJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isLowerCase(/ s/.*/internal fun isLowerCase(codepoint: Int): Boolean = isLowerCaseJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun toLowerCase(/ s/.*/internal fun toLowerCase(codepoint: Int): Int = toLowerCaseJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun toUpperCase(/ s/.*/internal fun toUpperCase(codepoint: Int): Int = toUpperCaseJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isSpaceChar(/ s/.*/internal fun isSpaceChar(codepoint: Int): Boolean = isSpaceCharJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isWhitespace(/ s/.*/internal fun isWhitespace(codepoint: Int): Boolean = isWhitespaceJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isIdeographic(/ s/.*/internal fun isIdeographic(codepoint: Int): Boolean = isIdeographicJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isIdentifierIgnorable(/ s/.*/internal fun isIdentifierIgnorable(codepoint: Int): Boolean = isIdentifierIgnorableJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isUnicodeIdentifierStart(/ s/.*/internal fun isUnicodeIdentifierStart(codepoint: Int): Boolean = isUnicodeIdentifierStartJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isUnicodeIdentifierPart(/ s/.*/internal fun isUnicodeIdentifierPart(codepoint: Int): Boolean = isUnicodeIdentifierPartJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isJavaIdentifierStart(/ s/.*/internal fun isJavaIdentifierStart(codepoint: Int): Boolean = isJavaIdentifierStartJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isJavaIdentifierPart(/ s/.*/internal fun isJavaIdentifierPart(codepoint: Int): Boolean = isJavaIdentifierPartJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun isISOControl(/ s/.*/internal fun isISOControl(codepoint: Int): Boolean = isISOControlJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt
sed -i '/fun getUnicodeScript(/ s/.*/internal fun getUnicodeScript(codepoint: Int): UnicodeScript = getUnicodeScriptJvm(codepoint)/' fleet/util/codepoints/srcCommonMain/fleet/codepoints/CodepointFunctions.kt

# Platform and syntax multiplatform shims
sed -i 's/.*fun <T> threadLocalImpl.*/internal fun <T> threadLocalImpl(supplier: () -> T): ThreadLocalKmp<T> = threadLocalImplJvm(supplier)/' platform/util/multiplatform/src/com/intellij/util/ThreadLocalKmp.kt
sed -i 's/= linkToActual()/= currentJavaVersionPlatformSpecificJvm()/' platform/util/multiplatform/src/com/intellij/util/JavaVersionShim.kt
sed -i 's/.*fun getCharsPlatformSpecific.*/internal fun getCharsPlatformSpecific(sequence: CharSequence, srcOffset: Int, dst: CharArray, dstOffset: Int, len: Int): Boolean = getCharsPlatformSpecificJvm(sequence, srcOffset, dst, dstOffset, len)/' platform/util/base/multiplatform/src/com/intellij/util/text/CharArrayUtilKmp.kt
sed -i 's/.*fun fromSequenceWithoutCopyingPlatformSpecific.*/internal fun fromSequenceWithoutCopyingPlatformSpecific(seq: CharSequence?): CharArray? = fromSequenceWithoutCopyingPlatformSpecificJvm(seq)/' platform/util/base/multiplatform/src/com/intellij/util/text/CharArrayUtilKmp.kt
sed -i 's/.*fun <K : Any, V : Any> newConcurrentMap.*/internal fun <K : Any, V : Any> newConcurrentMap(): MultiplatformConcurrentMap<K, V> = newConcurrentMapJvm()/' platform/syntax/syntax-extensions/src/com/intellij/platform/syntax/extensions/impl/CollectionsImpl.kt
sed -i 's/.*fun <V : Any> newConcurrentSet.*/internal fun <V : Any> newConcurrentSet(): MutableSet<V> = newConcurrentSetJvm()/' platform/syntax/syntax-extensions/src/com/intellij/platform/syntax/extensions/impl/CollectionsImpl.kt
sed -i 's/.*fun instantiateExtensionRegistry.*/internal fun instantiateExtensionRegistry(): ExtensionSupport = instantiateExtensionRegistryJvm()/' platform/syntax/syntax-extensions/src/com/intellij/platform/syntax/extensions/impl/ExtensionRegistryHolder.kt
sed -i 's/.*fun instantiateThreadLocalRegistry.*/internal fun instantiateThreadLocalRegistry(): RegistryHolder = instantiateThreadLocalRegistryJvm()/' platform/syntax/syntax-extensions/src/com/intellij/platform/syntax/extensions/impl/ExtensionRegistryHolder.kt
sed -i 's/.*fun newChameleonRef().*/fun newChameleonRef(): ChameleonRef = newChameleonRefJvm()/' platform/syntax/syntax-api/src/com/intellij/platform/syntax/tree/ASTMarkers.kt
sed -i 's/.*fun newChameleonRef(chameleon: AstMarkersChameleon).*/fun newChameleonRef(chameleon: AstMarkersChameleon): ChameleonRef = newChameleonRefJvm(chameleon)/' platform/syntax/syntax-api/src/com/intellij/platform/syntax/tree/ASTMarkers.kt
sed -i 's/.*fun makeStackTraceRelative.*/internal fun makeStackTraceRelative(th: Throwable, relativeTo: Throwable): Throwable = makeStackTraceRelativeJvm(th, relativeTo)/' platform/syntax/syntax-api/src/com/intellij/platform/syntax/impl/builder/MarkerProduction.kt
sed -i 's/= linkToActual()/= ResourceBundleJvm(bundleClass, pathToBundle, self, defaultMapping)/' platform/syntax/syntax-i18n/src/com/intellij/platform/syntax/i18n/ResourceBundle.kt

# Workaround for missing RPC plugin during JPS build (causes crash in listBundledPlugins)
# We patch FleetApi.kt so remoteApiDescriptor() returns a dummy descriptor that only implements getApiFqn().
# This allows RemoteApiProviderService.resolve() to find the locally registered backend instance without crashing.
cat << 'EOF' > patch-fleet-api.sh
sed -i -e '/inline fun <reified T : RemoteApi<\*>> remoteApiDescriptor/,+2c\
inline fun <reified T : RemoteApi<*>> remoteApiDescriptor(descriptor: RemoteApiDescriptor<T>? = null): RemoteApiDescriptor<T> {\
  return descriptor ?: object : RemoteApiDescriptor<T> {\
    override fun getSignature(methodName: String): RpcSignature = error("Not implemented")\
    override fun clientStub(proxy: suspend (String, Array<Any?>) -> Any?): T = error("Not implemented")\
    override fun getApiFqn(): String = T::class.qualifiedName ?: "Unknown"\
    override suspend fun call(impl: T, methodName: String, args: Array<Any?>): Any? = error("Not implemented")\
  }\
}' fleet/rpc/srcCommonMain/fleet/rpc/FleetApi.kt
EOF
bash patch-fleet-api.sh
rm patch-fleet-api.sh

# Fix NPE in FontGlyphHashCache when not running on JBR
sed -i 's/JBR.getFontExtensions().getEnabledFeatures(f).joinToString(",")/(JBR.getFontExtensions()?.getEnabledFeatures(f)?.joinToString(",") ?: "")/' platform/platform-impl/src/com/intellij/application/options/colors/FontGlyphHashCache.kt

# Workaround for invalid/empty ZIP files crashing ClassFileChecker
cat << 'EOF' > patch-class-file-checker.sh
sed -i -e '/if (fullPath.endsWith(".zip") || fullPath.endsWith(".jar")) {/,+2c\
    if (fullPath.endsWith(".zip") || fullPath.endsWith(".jar")) {\
      try { visitZip(zipPath = fullPath, zipRelPath = relativePath, file = ZipFile(FileChannel.open(file, READ)), errors = errors) }\
      catch (e: Exception) { System.err.println("WARN: Failed to read ZIP file: $fullPath: ${e.message}") }\
    }' platform/build-scripts/src/org/jetbrains/intellij/build/impl/ClassFileChecker.kt
EOF
bash patch-class-file-checker.sh
rm patch-class-file-checker.sh
