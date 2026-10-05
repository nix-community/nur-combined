package coil3.network

open class HttpException : RuntimeException() {
    open val response: NetworkResponse? = null
}

open class NetworkResponse {
    open val code: Int = 0
}
