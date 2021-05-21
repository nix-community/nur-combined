#include <stdio.h>
#include <glib.h>

#include "notification.h"

void hydrate_notification(notification_t *notification, GVariant *parameters) {
    GVariantIter iterator;

    g_variant_iter_init(&iterator, parameters);

    g_variant_iter_next(&iterator, "s",      &notification->name);
    g_variant_iter_next(&iterator, "u",      &notification->id);
    g_variant_iter_next(&iterator, "s",      &notification->icon);
    g_variant_iter_next(&iterator, "s",      &notification->summary);
    g_variant_iter_next(&iterator, "s",      &notification->body);
    g_variant_iter_next(&iterator, "^a&s",   &notification->actions);
    g_variant_iter_next(&iterator, "@a{sv}", &notification->hints);
    g_variant_iter_next(&iterator, "i",      &notification->timeout);
}
