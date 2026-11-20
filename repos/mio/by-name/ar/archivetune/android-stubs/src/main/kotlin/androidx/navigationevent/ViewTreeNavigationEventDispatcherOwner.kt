package androidx.navigationevent

import android.view.View

/*
 * Desktop stand-in for the Android-only view-tree lookup. The real
 * androidx.navigationevent desktop artefact on the runtime classpath provides
 * NavigationEventDispatcherOwner itself; only this extension is missing, so
 * returning null falls back to the composition-provided dispatcher owner.
 */
fun View.findViewTreeNavigationEventDispatcherOwner(): NavigationEventDispatcherOwner? = null
