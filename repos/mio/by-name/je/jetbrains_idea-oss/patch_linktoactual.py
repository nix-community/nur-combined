import os, re
import sys

replacements = {
    "fun <K, V> MultiplatformConcurrentHashMap(): MultiplatformConcurrentHashMap<K, V> = linkToActual()": "fun <K, V> MultiplatformConcurrentHashMap(): MultiplatformConcurrentHashMap<K, V> = MultiplatformConcurrentHashMapJvm()",
    "fun <T> MultiplatformConcurrentHashSet(): MultiplatformConcurrentHashSet<T> = linkToActual()": "fun <T> MultiplatformConcurrentHashSet(): MultiplatformConcurrentHashSet<T> = MultiplatformConcurrentHashSetJvm()",
    "internal fun threadLocalImpl(supplier: () -> Any?): ThreadLocal<Any?> = linkToActual()": "internal fun threadLocalImpl(supplier: () -> Any?): ThreadLocal<Any?> = threadLocalImplJvm(supplier)",
    "inline fun synchronizedImpl(lock: SynchronizedObject, block: () -> Any?): Any? = linkToActual()": "inline fun synchronizedImpl(lock: SynchronizedObject, block: () -> Any?): Any? = synchronizedImplJvm(lock, block)",
    "fun SynchronizedObject(): SynchronizedObject = linkToActual()": "fun SynchronizedObject(): SynchronizedObject = SynchronizedObjectJvm()",
    "fun currentThreadId(): Long = linkToActual()": "fun currentThreadId(): Long = currentThreadIdJvm()",
    "fun currentThreadName(): String = linkToActual()": "fun currentThreadName(): String = currentThreadNameJvm()",
    "internal fun DispatchersIO(): CoroutineDispatcher = linkToActual()": "internal fun DispatchersIO(): CoroutineDispatcher = DispatchersIOJvm()",
    "suspend fun runInterruptibleImpl(context: CoroutineContext, block: () -> Any?): Any? = linkToActual()": "suspend fun runInterruptibleImpl(context: CoroutineContext, block: () -> Any?): Any? = runInterruptibleImplJvm(context, block)",
    "): HighPriorityCoroutineDispatcherResource = linkToActual()": "): HighPriorityCoroutineDispatcherResource = newSingleThreadCoroutineDispatcherJvm(name, priority)",
    "internal fun getLoggerFactory(): KLoggerFactory = linkToActual()": "internal fun getLoggerFactory(): KLoggerFactory = getLoggerFactoryJvm()",
    "fun String.capitalizeWithCurrentLocale(): String = linkToActual()": "fun String.capitalizeWithCurrentLocale(): String = capitalizeWithCurrentLocaleJvm()",
    "fun String.lowercaseWithCurrentLocale(): String = linkToActual()": "fun String.lowercaseWithCurrentLocale(): String = lowercaseWithCurrentLocaleJvm()",
    "fun String.uppercaseWithCurrentLocale(): String = linkToActual()": "fun String.uppercaseWithCurrentLocale(): String = uppercaseWithCurrentLocaleJvm()",
    "fun String.isValidUriString(): Boolean = linkToActual()": "fun String.isValidUriString(): Boolean = isValidUriStringJvm()",
    "internal fun getName(): String = linkToActual()": "internal fun getName(): String = getNameJvm()",
    "internal fun getVersion(): String = linkToActual()": "internal fun getVersion(): String = getVersionJvm()",
    "internal fun getArch(): String = linkToActual()": "internal fun getArch(): String = getArchJvm()",
    "internal fun codepointsToString(vararg codepoints: Int): String = linkToActual()": "internal fun codepointsToString(vararg codepoints: Int): String = codepointsToStringJvm(*codepoints)",
    "internal fun codepointOf(highSurrogate: Char, lowSurrogate: Char): Codepoint = linkToActual()": "internal fun codepointOf(highSurrogate: Char, lowSurrogate: Char): Codepoint = codepointOfJvm(highSurrogate, lowSurrogate)",
    "internal fun highSurrogate(codepoint: Int): Char = linkToActual()": "internal fun highSurrogate(codepoint: Int): Char = highSurrogateJvm(codepoint)",
    "internal fun lowSurrogate(codepoint: Int): Char = linkToActual()": "internal fun lowSurrogate(codepoint: Int): Char = lowSurrogateJvm(codepoint)",
    "internal fun isLetter(codepoint: Int): Boolean = linkToActual()": "internal fun isLetter(codepoint: Int): Boolean = isLetterJvm(codepoint)",
    "internal fun isDigit(codepoint: Int): Boolean = linkToActual()": "internal fun isDigit(codepoint: Int): Boolean = isDigitJvm(codepoint)",
    "internal fun isLetterOrDigit(codepoint: Int): Boolean = linkToActual()": "internal fun isLetterOrDigit(codepoint: Int): Boolean = isLetterOrDigitJvm(codepoint)",
    "internal fun isUpperCase(codepoint: Int): Boolean = linkToActual()": "internal fun isUpperCase(codepoint: Int): Boolean = isUpperCaseJvm(codepoint)",
    "internal fun isLowerCase(codepoint: Int): Boolean = linkToActual()": "internal fun isLowerCase(codepoint: Int): Boolean = isLowerCaseJvm(codepoint)",
    "internal fun toLowerCase(codepoint: Int): Int = linkToActual()": "internal fun toLowerCase(codepoint: Int): Int = toLowerCaseJvm(codepoint)",
    "internal fun toUpperCase(codepoint: Int): Int = linkToActual()": "internal fun toUpperCase(codepoint: Int): Int = toUpperCaseJvm(codepoint)",
    "internal fun isSpaceChar(codepoint: Int): Boolean = linkToActual()": "internal fun isSpaceChar(codepoint: Int): Boolean = isSpaceCharJvm(codepoint)",
    "internal fun isWhitespace(codepoint: Int): Boolean = linkToActual()": "internal fun isWhitespace(codepoint: Int): Boolean = isWhitespaceJvm(codepoint)",
    "internal fun isIdeographic(codepoint: Int): Boolean = linkToActual()": "internal fun isIdeographic(codepoint: Int): Boolean = isIdeographicJvm(codepoint)",
    "internal fun isIdentifierIgnorable(codepoint: Int): Boolean = linkToActual()": "internal fun isIdentifierIgnorable(codepoint: Int): Boolean = isIdentifierIgnorableJvm(codepoint)",
    "internal fun isUnicodeIdentifierStart(codepoint: Int): Boolean = linkToActual()": "internal fun isUnicodeIdentifierStart(codepoint: Int): Boolean = isUnicodeIdentifierStartJvm(codepoint)",
    "internal fun isUnicodeIdentifierPart(codepoint: Int): Boolean = linkToActual()": "internal fun isUnicodeIdentifierPart(codepoint: Int): Boolean = isUnicodeIdentifierPartJvm(codepoint)",
    "internal fun isJavaIdentifierStart(codepoint: Int): Boolean = linkToActual()": "internal fun isJavaIdentifierStart(codepoint: Int): Boolean = isJavaIdentifierStartJvm(codepoint)",
    "internal fun isJavaIdentifierPart(codepoint: Int): Boolean = linkToActual()": "internal fun isJavaIdentifierPart(codepoint: Int): Boolean = isJavaIdentifierPartJvm(codepoint)",
    "internal fun isISOControl(codepoint: Int): Boolean = linkToActual()": "internal fun isISOControl(codepoint: Int): Boolean = isISOControlJvm(codepoint)",
    "internal fun getUnicodeScript(codepoint: Int): UnicodeScript = linkToActual()": "internal fun getUnicodeScript(codepoint: Int): UnicodeScript = getUnicodeScriptJvm(codepoint)"
}

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    if 'linkToActual()' not in content:
        return

    lines = content.split('\n')
    new_lines = []
    changed = False
    
    for line in lines:
        new_line = line
        for k, v in replacements.items():
            if k in line:
                new_line = line.replace(k, v)
                changed = True
                break
        new_lines.append(new_line)
        
    if changed:
        with open(filepath, 'w') as f:
            f.write('\n'.join(new_lines))
        print(f"Patched {filepath}")

for root, _, files in os.walk('fleet'):
    for file in files:
        if file.endswith('.kt'):
            process_file(os.path.join(root, file))
