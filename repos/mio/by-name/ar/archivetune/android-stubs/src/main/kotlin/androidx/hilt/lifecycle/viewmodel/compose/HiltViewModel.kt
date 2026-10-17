package androidx.hilt.lifecycle.viewmodel.compose

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.lifecycle.ViewModel
import androidx.navigation.NavController

@Composable
inline fun <reified VM : ViewModel> hiltViewModel(): VM {
    val backStackEntry = androidx.navigation.compose.LocalCurrentBackStackEntry.current
        ?: NavController.globalInstance?.currentBackStackEntry
    val savedStateHandle = backStackEntry?.savedStateHandle
    return remember(backStackEntry, VM::class.java) {
        androidx.hilt.navigation.compose._createViewModelInstance(VM::class.java, savedStateHandle) as VM
    }
}

fun _createViewModelInstance(clazz: Class<*>, savedStateHandle: androidx.lifecycle.SavedStateHandle? = null): Any? {
    return androidx.hilt.navigation.compose._createViewModelInstance(clazz, savedStateHandle)
}

