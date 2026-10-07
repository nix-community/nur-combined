package androidx.hilt.lifecycle.viewmodel.compose

import androidx.compose.runtime.Composable
import androidx.lifecycle.ViewModel

@Composable
inline fun <reified VM : ViewModel> hiltViewModel(): VM {
    return androidx.hilt.navigation.compose._createViewModelInstance(VM::class.java) as VM
}

fun _createViewModelInstance(clazz: Class<*>): Any? {
    return androidx.hilt.navigation.compose._createViewModelInstance(clazz)
}
