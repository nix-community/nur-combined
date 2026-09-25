package okio

abstract class ForwardingSource(val delegate: Source) : Source {
    override fun read(sink: Buffer, byteCount: Long): Long = -1L
    override fun close() {}
}
