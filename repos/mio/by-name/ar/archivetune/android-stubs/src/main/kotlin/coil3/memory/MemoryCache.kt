package coil3.memory

/* Coil's in-memory image cache; upstream only clears it. */
open class MemoryCache {
    open fun clear() {}

    open val size: Long = 0L
}
