// SPDX-FileCopyrightText: 2017 - 2022 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include <QApplication>
#include <QTranslator>
#include <QLockFile>
#include <QStandardPaths>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QTextStream>

#include <PolkitQt1/Subject>

#include "policykitlistener.h"
#include "accessible.h"

#define APP_NAME "dde-polkit-agent"
#define APP_DISPLAY_NAME "Lingmo Polkit Agent"
#define AUTH_DBUS_PATH "/com/deepin/dde/Polkit1/AuthAgent"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    a.setOrganizationName("lingmo");
    a.setApplicationName(APP_NAME);
    a.setApplicationDisplayName(APP_DISPLAY_NAME);
    a.setApplicationVersion("0.1");
    a.setQuitOnLastWindowClosed(false);

    // Single instance check
    QString lockPath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation)
                       + QDir::separator() + APP_NAME + ".lock";
    QLockFile lockFile(lockPath);
    if (!lockFile.tryLock(100)) {
        qWarning() << "polkit is running!";
        return 0;
    }

    QAccessible::installFactory(accessibleFactory);

    PolkitQt1::UnixSessionSubject session(getpid());
    PolicyKitListener listener;

    if (!listener.registerListener(session, AUTH_DBUS_PATH)) {
        qWarning() << "register listener failed!";
        return -1;
    }

    QTranslator translator;
    translator.load(QLocale(), APP_NAME, "_", ":/translations");
    a.installTranslator(&translator);

    // create PID file to ~/.cache/deepin/dde-polkit-agent
    const QString cachePath = QStandardPaths::standardLocations(QStandardPaths::CacheLocation).first();

    QDir dir(cachePath);
    if (!dir.exists()) {
        dir.mkpath(cachePath);
    }

    QFile PID(cachePath + QDir::separator() + "pid");
    if (PID.open(QIODevice::WriteOnly)) {
        QTextStream out(&PID);
        out << getpid();
        PID.close();
    }

    return a.exec();
}
