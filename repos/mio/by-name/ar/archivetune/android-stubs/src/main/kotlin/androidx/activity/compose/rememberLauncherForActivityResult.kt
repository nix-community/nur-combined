package androidx.activity.compose

import androidx.compose.runtime.Composable

class ManagedActivityResultLauncher<I, O> {
    fun launch(input: I) {}
}

@Composable
fun <I, O> rememberLauncherForActivityResult(
    contract: Any,
    onResult: (O) -> Unit
): ManagedActivityResultLauncher<I, O> = ManagedActivityResultLauncher()
