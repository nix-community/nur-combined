from pathlib import Path

source = Path(
    "lineage/lib/main/java/org/lineageos/platform/internal/WayDroidService.java"
)
text = source.read_text()


def replace_once(old, new, description):
    global text
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"Expected one {description}, found {count}")
    text = text.replace(old, new, 1)


for import_name in ("BroadcastReceiver", "IntentFilter", "IntentSender"):
    import_line = f"import android.content.{import_name};\n"
    if import_line not in text:
        replace_once(
            "import android.content.Intent;\n",
            "import android.content.Intent;\n" + import_line,
            f"anchor for {import_name} import",
        )

delete_observer_import = "import android.content.pm.IPackageDeleteObserver;\n"
if delete_observer_import not in text:
    replace_once(
        "import android.content.pm.PackageInstaller;\n",
        "import android.content.pm.PackageInstaller;\n" + delete_observer_import,
        "anchor for IPackageDeleteObserver import",
    )

for import_name in ("CountDownLatch", "TimeUnit", "atomic.AtomicInteger"):
    full_name = f"java.util.concurrent.{import_name}"
    import_line = f"import {full_name};\n"
    if import_line not in text:
        replace_once(
            "import java.io.FileOutputStream;\n",
            "import java.io.FileOutputStream;\n" + import_line,
            f"anchor for {full_name} import",
        )

if "import android.os.Binder;\n" not in text:
    replace_once(
        "import android.os.IBinder;\n",
        "import android.os.Binder;\nimport android.os.IBinder;\n",
        "anchor for Binder import",
    )

helper = '''    private interface PackageInstallerOperation {
        void commit(IntentSender result) throws Exception;
    }

    private int removePackage(String packageName) {
        final CountDownLatch completed = new CountDownLatch(1);
        final AtomicInteger result = new AtomicInteger(PackageManager.DELETE_FAILED_INTERNAL_ERROR);
        final long identity = Binder.clearCallingIdentity();
        try {
            mPm.deletePackageAsUser(packageName, new IPackageDeleteObserver.Stub() {
                @Override
                public void packageDeleted(String deletedPackage, int returnCode) {
                    result.set(returnCode);
                    completed.countDown();
                }
            }, PackageManager.DELETE_ALL_USERS, UserHandle.USER_SYSTEM);
            if (!completed.await(120, TimeUnit.SECONDS)) {
                Log.e(TAG, "Timed out waiting for package removal: " + packageName);
                return -3000;
            }
            if (result.get() != PackageManager.DELETE_SUCCEEDED) {
                Log.e(TAG, "Package removal failed for " + packageName
                        + " with code " + result.get());
                return -1000 + result.get();
            }
            return 0;
        } catch (Exception e) {
            Log.e(TAG, "Package removal failed: " + packageName, e);
            return -2000;
        } finally {
            Binder.restoreCallingIdentity(identity);
        }
    }

    private int commitPackageOperation(String action, int requestCode,
            PackageInstallerOperation operation) {
        final CountDownLatch completed = new CountDownLatch(1);
        final AtomicInteger status = new AtomicInteger(PackageInstaller.STATUS_FAILURE);
        final String uniqueAction = action + "." + requestCode;
        final IntentFilter filter = new IntentFilter(uniqueAction);
        final BroadcastReceiver receiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                status.set(intent.getIntExtra(PackageInstaller.EXTRA_STATUS,
                        PackageInstaller.STATUS_FAILURE));
                if (status.get() != PackageInstaller.STATUS_SUCCESS) {
                    Log.e(TAG, "Package operation failed: " + intent.getStringExtra(
                            PackageInstaller.EXTRA_STATUS_MESSAGE));
                }
                completed.countDown();
            }
        };

        mContext.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED);
        try {
            Intent resultIntent = new Intent(uniqueAction).setPackage(mContext.getPackageName());
            PendingIntent pendingIntent = PendingIntent.getBroadcast(mContext, requestCode,
                    resultIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE);
            operation.commit(pendingIntent.getIntentSender());
            if (!completed.await(120, TimeUnit.SECONDS)) {
                Log.e(TAG, "Timed out waiting for PackageInstaller result: " + uniqueAction);
                return -1;
            }
            return status.get() == PackageInstaller.STATUS_SUCCESS ? 0 : -1;
        } catch (Exception e) {
            Log.e(TAG, "PackageInstaller operation failed: " + uniqueAction, e);
            return -1;
        } finally {
            mContext.unregisterReceiver(receiver);
        }
    }

'''
replace_once(
    "    private final IBinder mPlatformService = new IPlatform.Stub() {",
    helper + "    private final IBinder mPlatformService = new IPlatform.Stub() {",
    "IPlatform binder anchor",
)

install_before = '''                // Create a PendingIntent and use it to generate the IntentSender
                Intent broadcastIntent = new Intent(BROADCAST_ACTION_INSTALL);
                PendingIntent pendingIntent = PendingIntent.getBroadcast(
                        mContext,
                        sessionId,
                        broadcastIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
                session.commit(pendingIntent.getIntentSender());'''
install_after = '''                // Wait for Android's asynchronous package-manager result before
                // returning success to the host client.
                final PackageInstaller.Session installSession = session;
                ret = commitPackageOperation(BROADCAST_ACTION_INSTALL, sessionId,
                        result -> installSession.commit(result));'''
replace_once(install_before, install_after, "install commit block")

remove_before = '''          // Create a PendingIntent and use it to generate the IntentSender
          Intent broadcastIntent = new Intent(BROADCAST_ACTION_UNINSTALL);
          PendingIntent pendingIntent = PendingIntent.getBroadcast(
                  mContext, // context
                  0, // arbitary
                  broadcastIntent,
                  PendingIntent.FLAG_UPDATE_CURRENT);
          packageInstaller.uninstall(packageName, pendingIntent.getIntentSender());

          return 0;'''
remove_after = '''          return removePackage(packageName);'''
replace_once(remove_before, remove_after, "uninstall commit block")
replace_once(
    "          mPm.setInstallerPackageName(packageName, mContext.getPackageName());\n",
    "",
    "obsolete installer-package mutation",
)

source.write_text(text)
