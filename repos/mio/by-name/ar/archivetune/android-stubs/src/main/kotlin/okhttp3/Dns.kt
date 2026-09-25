package okhttp3


interface Dns {
    companion object {
        val SYSTEM: Dns = object : Dns {
            override fun lookup(hostname: String): List<java.net.InetAddress> = emptyList()
        }
    }
    fun lookup(hostname: String): List<java.net.InetAddress>
}

