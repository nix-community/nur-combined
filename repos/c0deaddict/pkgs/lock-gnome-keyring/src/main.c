#include <stdio.h>
#include <gnome-keyring.h>

int main() {
    GnomeKeyringResult lock_result = gnome_keyring_lock_all_sync();
    if (lock_result == GNOME_KEYRING_RESULT_OK) {
        printf("Successfully locked\n");
        return 0;
    } else {
        printf("Error locking keyring: %d\n", lock_result);
        return 1;
    }
}
