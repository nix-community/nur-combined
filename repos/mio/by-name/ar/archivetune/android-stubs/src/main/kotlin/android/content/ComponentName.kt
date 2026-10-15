package android.content

open class ComponentName(val packageName: String, val className: String) {
    constructor(context: Context, cls: Class<*>) : this(context.packageName, cls.name)
    constructor(pkg: String, cls: Class<*>) : this(pkg, cls.name)

    fun getShortClassName(): String = className.substringAfterLast('.')

    override fun equals(other: Any?): Boolean =
        other is ComponentName && packageName == other.packageName && className == other.className

    override fun hashCode(): Int = packageName.hashCode() * 31 + className.hashCode()

    override fun toString(): String = "ComponentInfo{$packageName/$className}"
}
