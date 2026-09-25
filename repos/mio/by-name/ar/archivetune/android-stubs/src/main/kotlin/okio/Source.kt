package okio

interface Source {
    fun read(sink: Buffer, byteCount: Long): Long
    fun close()
}
