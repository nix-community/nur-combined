package android.net

open class Network

open class NetworkCapabilities {
    open fun hasCapability(capability: Int): Boolean = true
    open fun hasTransport(transport: Int): Boolean = true

    companion object {
        const val NET_CAPABILITY_INTERNET = 12
        const val NET_CAPABILITY_NOT_METERED = 11
        const val NET_CAPABILITY_NOT_RESTRICTED = 13
        const val NET_CAPABILITY_VALIDATED = 16
        const val TRANSPORT_CELLULAR = 0
        const val TRANSPORT_WIFI = 1
        const val TRANSPORT_BLUETOOTH = 2
        const val TRANSPORT_ETHERNET = 3
        const val TRANSPORT_VPN = 4
    }
}

open class NetworkRequest {
    open class Builder {
        fun addCapability(capability: Int): Builder = this
        fun removeCapability(capability: Int): Builder = this
        fun addTransportType(transportType: Int): Builder = this
        fun removeTransportType(transportType: Int): Builder = this
        fun build(): NetworkRequest = NetworkRequest()
    }
}

open class ConnectivityManager {
    open class NetworkCallback {
        open fun onAvailable(network: Network) {}
        open fun onLost(network: Network) {}
        open fun onCapabilitiesChanged(network: Network, networkCapabilities: NetworkCapabilities) {}
        open fun onUnavailable() {}
    }

    private val defaultNetwork = Network()
    private val defaultCapabilities = NetworkCapabilities()

    open val activeNetwork: Network? get() = defaultNetwork
    open val isActiveNetworkMetered: Boolean get() = false

    open fun getNetworkCapabilities(network: Network?): NetworkCapabilities? =
        if (network != null) defaultCapabilities else null

    open fun registerDefaultNetworkCallback(networkCallback: NetworkCallback) {
        networkCallback.onAvailable(defaultNetwork)
        networkCallback.onCapabilitiesChanged(defaultNetwork, defaultCapabilities)
    }

    open fun registerNetworkCallback(request: NetworkRequest, networkCallback: NetworkCallback) {
        networkCallback.onAvailable(defaultNetwork)
        networkCallback.onCapabilitiesChanged(defaultNetwork, defaultCapabilities)
    }

    open fun unregisterNetworkCallback(networkCallback: NetworkCallback) {}
}
