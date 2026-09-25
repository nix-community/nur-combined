package dagger.hilt
@Target(AnnotationTarget.CLASS)
annotation class InstallIn(val value: kotlin.reflect.KClass<out Any>)
