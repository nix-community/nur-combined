package androidx.work
open class Constraints {
    open class Builder {
        fun setRequiresDeviceIdle(requires: Boolean): Builder = this
        fun setRequiresCharging(requires: Boolean): Builder = this
        fun setRequiresBatteryNotLow(requires: Boolean): Builder = this
        fun setRequiresStorageNotLow(requires: Boolean): Builder = this
        fun build(): Constraints = Constraints()
    }
}
