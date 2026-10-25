// SPDX-License-Identifier: MIT
// Read-only, on-demand bridge to the public Akonadi API. No database inspection.
#include <Akonadi/Collection>
#include <Akonadi/CollectionFetchJob>
#include <Akonadi/CollectionFetchScope>
#include <Akonadi/Item>
#include <Akonadi/ItemFetchJob>
#include <Akonadi/ItemFetchScope>
#include <Akonadi/ServerManager>
#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTextStream>
#include <QTimer>
#include <QUrl>
#include <cstdlib>

static int fail(const QString &message) {
    QTextStream(stderr) << message << '\n';
    return 2;
}
int main(int argc, char **argv) {
    QCoreApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("spotlight-pim"));
    const auto args = app.arguments();
    if (args.size() != 2 || (args[1] != QLatin1String("contacts") && args[1] != QLatin1String("calendar") && args[1] != QLatin1String("calendar-busy")))
        return fail(QStringLiteral("Usage: spotlight-pim contacts|calendar|calendar-busy"));
    const bool busy = args[1] == QLatin1String("calendar-busy");
    if (!Akonadi::ServerManager::isRunning())
        return fail(QStringLiteral("Akonadi is not running. Open KAddressBook or KOrganizer and configure an account first."));
    QTimer::singleShot(8500, &app, [] { QTextStream(stderr) << "Akonadi search timed out\n"; std::exit(3); });
    const bool contacts = args[1] == QLatin1String("contacts");
    const QStringList mimes = contacts
        ? QStringList{QStringLiteral("text/directory"), QStringLiteral("text/vcard")}
        : QStringList{QStringLiteral("text/calendar"), QStringLiteral("application/x-vnd.akonadi.calendar.event")};
    auto collections = new Akonadi::CollectionFetchJob(Akonadi::Collection::root(), Akonadi::CollectionFetchJob::Recursive, &app);
    collections->fetchScope().setContentMimeTypes(mimes);
    if (!busy) collections->fetchScope().setListFilter(Akonadi::CollectionFetchScope::Display);
    if (!collections->exec()) return fail(collections->errorText());
    QJsonArray output;
    qsizetype budget = 2;
    int count = 0;
    int calendars = 0;
    for (const auto &collection : collections->collections()) {
        if (++count > 100 || output.size() >= 2000) {if (busy) return fail(QStringLiteral("Too many cached calendars or events for a complete availability check"));break;}
        bool supported = false;
        for (const auto &mime : mimes) if (collection.contentMimeTypes().contains(mime)) supported = true;
        if (!supported || collection.isVirtual()) continue;
        ++calendars;
        auto items = new Akonadi::ItemFetchJob(collection, &app);
        items->fetchScope().fetchFullPayload();
        items->fetchScope().setCacheOnly(true);
        items->fetchScope().setIgnoreRetrievalErrors(!busy);
        items->setLimit(qMin(500, 2000 - int(output.size())), 0);
        if (!items->exec()) return fail(items->errorText());
        if (busy && items->items().size() >= 500) return fail(QStringLiteral("A cached calendar reached the 500-item limit; availability was not computed"));
        for (const auto &item : items->items()) {
            if (!mimes.contains(item.mimeType())) continue;
            const QByteArray payload = item.payloadData();
            if (payload.isEmpty() || payload.size() > 65536) {if (busy) return fail(QStringLiteral("A cached calendar event is unavailable or exceeds 64 KiB"));continue;}
            QJsonObject record{{QStringLiteral("payload"), QString::fromUtf8(payload)},
                               {QStringLiteral("collection"), busy ? QString::number(collection.id()) : collection.displayName()},
                               {QStringLiteral("uri"), item.url().toString()}};
            const auto size = QJsonDocument(record).toJson(QJsonDocument::Compact).size() + 1;
            if (budget + size > 900000) {if (busy) return fail(QStringLiteral("Cached calendar data exceeds the availability budget"));break;}
            budget += size;
            output.append(record);
        }
        delete items;
    }
    if (busy && !calendars) return fail(QStringLiteral("No Akonadi calendar collections are configured"));
    QTextStream(stdout) << QJsonDocument(output).toJson(QJsonDocument::Compact) << '\n';
    return 0;
}
