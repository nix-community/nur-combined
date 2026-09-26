package dagger.hilt.android.lifecycle

import androidx.compose.runtime.Composable
import androidx.lifecycle.ViewModel

@Composable
inline fun <reified VM : ViewModel> hiltViewModel(): VM = TODO()
