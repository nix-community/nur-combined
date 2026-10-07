package androidx.activity.result.contract

abstract class ActivityResultContract<I, O>

object ActivityResultContracts {
    class StartActivityForResult :
        ActivityResultContract<android.content.Intent, android.content.Intent?>()

    class StartIntentSenderForResult :
        ActivityResultContract<android.content.Intent, android.content.Intent?>()

    class RequestMultiplePermissions :
        ActivityResultContract<Array<String>, Map<String, Boolean>>()

    class RequestPermission : ActivityResultContract<String, Boolean>()
    class CreateDocument(val mimeType: String) : ActivityResultContract<String, android.net.Uri?>()
    class OpenDocument : ActivityResultContract<Array<String>, android.net.Uri?>()
    class GetContent : ActivityResultContract<String, android.net.Uri?>()
    class OpenDocumentTree :
        ActivityResultContract<android.net.Uri?, android.net.Uri?>()

    class OpenMultipleDocuments :
        ActivityResultContract<Array<String>, List<android.net.Uri>>()

    class PickVisualMedia :
        ActivityResultContract<Any, android.net.Uri?>()
}
