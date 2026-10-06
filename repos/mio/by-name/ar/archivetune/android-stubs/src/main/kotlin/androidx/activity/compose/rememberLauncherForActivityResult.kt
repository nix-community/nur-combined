package androidx.activity.compose

import androidx.activity.result.contract.ActivityResultContract
import androidx.compose.runtime.Composable

class ManagedActivityResultLauncher<I, O> {
    fun launch(input: I) {}

    fun unregister() {}
}

/*
 * The contract parameter must carry its result type, otherwise `O` cannot be inferred
 * from the call and upstream's `{ uri -> ... }` lambdas fail with
 * "Cannot infer type for type parameter 'O'".
 */
@Composable
fun <I, O> rememberLauncherForActivityResult(
    contract: ActivityResultContract<I, O>,
    onResult: (O) -> Unit,
): ManagedActivityResultLauncher<I, O> = ManagedActivityResultLauncher()
