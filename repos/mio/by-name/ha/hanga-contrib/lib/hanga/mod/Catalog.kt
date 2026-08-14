package hanga.mod

object Catalog {
    fun parse(csv: String): List<String> =
        csv.split(',').map { it.trim() }.filter { it.isNotEmpty() }

    fun name(entries: List<String>, index: Int): String =
        entries.getOrNull(index) ?: "air"

    fun index(entries: List<String>, name: String): Int =
        entries.indexOf(name).takeIf { it >= 0 } ?: 0
}
