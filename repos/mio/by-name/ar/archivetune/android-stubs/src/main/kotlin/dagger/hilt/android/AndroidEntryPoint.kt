package dagger.hilt.android

/*
 * Hilt's entry-point annotation. Upstream annotates its Activities/Services with it;
 * the port has no Hilt codegen, so the annotation exists only to let those declarations
 * compile.
 */
@Target(AnnotationTarget.CLASS)
@Retention(AnnotationRetention.RUNTIME)
annotation class AndroidEntryPoint
