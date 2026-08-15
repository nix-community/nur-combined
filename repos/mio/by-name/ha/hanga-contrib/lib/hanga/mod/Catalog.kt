package hanga.mod

object Catalog {
    fun parse(csv: String): List<String> =
        csv.split(',').map { it.trim() }.filter { it.isNotEmpty() }

    fun name(entries: List<String>, index: Int): String =
        entries.getOrNull(index) ?: "air"

    fun index(entries: List<String>, name: String): Int =
        entries.indexOf(name).takeIf { it >= 0 } ?: 0

    /** Bedrock-style below, striped y==0, air above. */
    fun checkerFloor(x: Int, y: Int, z: Int): Int =
        when {
            y < 0 -> 2
            y == 0 -> if (((x + z) and 1) == 0) 1 else 2
            else -> 0
        }
}
