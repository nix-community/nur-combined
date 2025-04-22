package org.nixos.gradle2nix

import java.util.concurrent.ConcurrentHashMap

class Version(
    val source: String,
    val parts: List<String>,
    base: Version?,
) : Comparable<Version> {
    private val base: Version
    val numericParts: List<Long?>

    init {
        this.base = base ?: this
        this.numericParts =
            parts.map {
                try {
                    it.toLong()
                } catch (e: NumberFormatException) {
                    null
                }
            }
    }

    override fun compareTo(other: Version): Int = compare(this, other)

    override fun toString(): String = source

    override fun equals(other: Any?): Boolean =
        when {
            other === this -> true
            other == null || other !is Version -> false
            else -> source == other.source
        }

    override fun hashCode(): Int = source.hashCode()

    companion object {
        private val SPECIAL_MEANINGS: Map<String, Int> =
            mapOf(
                "dev" to -1,
                "rc" to 1,
                "snapshot" to 2,
                "final" to 3,
                "ga" to 4,
                "release" to 5,
                "sp" to 6,
            )

        private val cache = ConcurrentHashMap<String, Version>()

        // From org.gradle.api.internal.artifacts.ivyservice.ivyresolve.strategy.VersionParser
        operator fun invoke(original: String): Version =
            cache.getOrPut(original) {
                val parts = mutableListOf<String>()
                var digit = false
                var startPart = 0
                var pos = 0
                var endBase = 0
                var endBaseStr = 0
                while (pos < original.length) {
                    val ch = original[pos]
                    if (ch == '.' || ch == '_' || ch == '-' || ch == '+') {
                        parts.add(original.substring(startPart, pos))
                        startPart = pos + 1
                        digit = false
                        if (ch != '.' && endBaseStr == 0) {
                            endBase = parts.size
                            endBaseStr = pos
                        }
                    } else if (ch in '0'..'9') {
                        if (!digit && pos > startPart) {
                            if (endBaseStr == 0) {
                                endBase = parts.size + 1
                                endBaseStr = pos
                            }
                            parts.add(original.substring(startPart, pos))
                            startPart = pos
                        }
                        digit = true
                    } else {
                        if (digit) {
                            if (endBaseStr == 0) {
                                endBase = parts.size + 1
                                endBaseStr = pos
                            }
                            parts.add(original.substring(startPart, pos))
                            startPart = pos
                        }
                        digit = false
                    }
                    pos++
                }
                if (pos > startPart) {
                    parts.add(original.substring(startPart, pos))
                }
                var base: Version? = null
                if (endBaseStr > 0) {
                    base = Version(original.substring(0, endBaseStr), parts.subList(0, endBase), null)
                }
                Version(original, parts, base)
            }

        // From org.gradle.api.internal.artifacts.ivyservice.ivyresolve.strategy.StaticVersionComparator
        private fun compare(
            version1: Version,
            version2: Version,
        ): Int {
            if (version1 == version2) {
                return 0
            }

            val parts1 = version1.parts
            val parts2 = version2.parts
            val numericParts1 = version1.numericParts
            val numericParts2 = version2.numericParts
            var lastIndex = -1

            for (i in 0..<(minOf(parts1.size, parts2.size))) {
                lastIndex = i

                val part1 = parts1[i]
                val part2 = parts2[i]

                val numericPart1 = numericParts1[i]
                val numericPart2 = numericParts2[i]

                when {
                    part1 == part2 -> continue
                    numericPart1 != null && numericPart2 == null -> return 1
                    numericPart2 != null && numericPart1 == null -> return -1
                    numericPart1 != null && numericPart2 != null -> {
                        val result = numericPart1.compareTo(numericPart2)
                        if (result == 0) continue
                        return result
                    }
                    else -> {
                        // both are strings, we compare them taking into account special meaning
                        val sm1 = SPECIAL_MEANINGS[part1.lowercase()]
                        val sm2 = SPECIAL_MEANINGS[part2.lowercase()]
                        if (sm1 != null) return sm1 - (sm2 ?: 0)
                        if (sm2 != null) return -sm2
                        return part1.compareTo(part2)
                    }
                }
            }
            if (lastIndex < parts1.size) {
                return if (numericParts1[lastIndex] == null) -1 else 1
            }
            if (lastIndex < parts2.size) {
                return if (numericParts2[lastIndex] == null) 1 else -1
            }

            return 0
        }
    }
}
