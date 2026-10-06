package androidx.compose.ui.tooling.preview

/*
 * compose-ui-tooling is an Android-only artifact; upstream only imports @Preview for its
 * preview functions, so an inert annotation is enough.
 */
@Retention(AnnotationRetention.BINARY)
@Target(
    AnnotationTarget.FUNCTION,
    AnnotationTarget.ANNOTATION_CLASS,
)
annotation class Preview(
    val name: String = "",
    val group: String = "",
    val showBackground: Boolean = false,
    val backgroundColor: Long = 0,
    val showSystemUi: Boolean = false,
    val widthDp: Int = -1,
    val heightDp: Int = -1,
    val locale: String = "",
)
