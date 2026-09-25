package androidx.room

@Target(AnnotationTarget.CLASS)
annotation class Database(val entities: Array<kotlin.reflect.KClass<*>> = [], val views: Array<kotlin.reflect.KClass<*>> = [], val version: Int = 1, val exportSchema: Boolean = true, val autoMigrations: Array<AutoMigration> = [])
