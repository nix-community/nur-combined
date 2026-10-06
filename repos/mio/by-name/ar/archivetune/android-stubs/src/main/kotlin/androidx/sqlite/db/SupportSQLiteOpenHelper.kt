package androidx.sqlite.db

/*
 * Room's helper contract. Upstream builds the helper itself via
 * `SupportSQLiteOpenHelper.Configuration.builder(context)...build()` plus
 * `SupportSQLiteOpenHelper.create(context, configuration)` and an anonymous
 * `SupportSQLiteOpenHelper.Callback(version)`, so the nested types and the factory
 * function must exist for those call sites to type-check.
 */
interface SupportSQLiteOpenHelper : AutoCloseable {
    val writableDatabase: SupportSQLiteDatabase

    val readableDatabase: SupportSQLiteDatabase

    fun setWriteAheadLoggingEnabled(enabled: Boolean)

    override fun close()

    class Configuration private constructor(
        val context: Any?,
        val name: String?,
        val callback: Callback?,
        val useNoBackupDirectory: Boolean,
        val allowDataLossOnRecovery: Boolean,
    ) {
        class Builder(val context: Any?) {
            fun name(name: String?): Builder = this

            fun callback(callback: Callback): Builder = this

            fun noBackupDirectory(noBackupDirectory: Boolean): Builder = this

            fun allowDataLossOnRecovery(allowDataLossOnRecovery: Boolean): Builder = this

            fun build(): Configuration = Configuration(context, null, null, false, false)
        }

        companion object {
            @JvmStatic
            fun builder(context: Any?): Builder = Builder(context)
        }
    }

    abstract class Callback(val version: Int) {
        open fun onCreate(db: SupportSQLiteDatabase) {}

        open fun onUpgrade(db: SupportSQLiteDatabase, oldVersion: Int, newVersion: Int) {}

        open fun onDowngrade(db: SupportSQLiteDatabase, oldVersion: Int, newVersion: Int) {}

        open fun onOpen(db: SupportSQLiteDatabase) {}

        open fun onConfigure(db: SupportSQLiteDatabase) {}
    }

    interface Factory {
        fun create(configuration: Configuration): SupportSQLiteOpenHelper
    }

    companion object {
        private val mockHelper = object : SupportSQLiteOpenHelper {
            private val db = java.lang.reflect.Proxy.newProxyInstance(
                SupportSQLiteDatabase::class.java.classLoader,
                arrayOf(SupportSQLiteDatabase::class.java)
            ) { _, method, _ ->
                val ret = method.returnType
                when {
                    ret == Boolean::class.java -> false
                    ret == Int::class.java -> 0
                    ret == Long::class.java -> 0L
                    else -> null
                }
            } as SupportSQLiteDatabase

            override val writableDatabase: SupportSQLiteDatabase = db
            override val readableDatabase: SupportSQLiteDatabase = db
            override fun setWriteAheadLoggingEnabled(enabled: Boolean) {}
            override fun close() {}
        }

        @JvmStatic
        fun create(
            context: Any?,
            name: String?,
            callback: Callback,
        ): SupportSQLiteOpenHelper = mockHelper

        @JvmStatic
        fun create(
            context: Any?,
            configuration: Configuration,
        ): SupportSQLiteOpenHelper = mockHelper
    }
}
