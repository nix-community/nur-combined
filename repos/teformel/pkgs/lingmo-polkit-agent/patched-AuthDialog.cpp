// SPDX-FileCopyrightText: 2017 - 2026 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "AuthDialog.h"
#include "usersmanager.h"

#include <QPainter>
#include <QDesktopServices>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QUrl>
#include <QAbstractButton>
#include <QButtonGroup>
#include <QPushButton>
#include <QIcon>
#include <QLabel>
#include <QGuiApplication>
#include <QScreen>
#include <QFile>
#include <QSettings>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusConnection>

#include <libintl.h>

// ─── PasswordEdit ────────────────────────────────────────────────────────────

PasswordEdit::PasswordEdit(QWidget *parent)
    : QLineEdit(parent)
    , m_toggleBtn(new QPushButton(this))
{
    setEchoMode(QLineEdit::Password);

    m_toggleBtn->setFixedSize(24, 24);
    m_toggleBtn->setCursor(Qt::PointingHandCursor);
    m_toggleBtn->setFlat(true);
    m_toggleBtn->setStyleSheet("QPushButton { border: none; background: transparent; }");
    m_toggleBtn->setText(QString::fromUtf8("\xE2\x97\x8F")); // "◉" toggle hint
    m_toggleBtn->setToolTip(tr("Show password"));

    connect(m_toggleBtn, &QPushButton::clicked, this, [this]() {
        if (echoMode() == QLineEdit::Password) {
            setEchoMode(QLineEdit::Normal);
            m_toggleBtn->setText(QString::fromUtf8("\xE2\x97\x8B")); // "○"
            m_toggleBtn->setToolTip(tr("Hide password"));
        } else {
            setEchoMode(QLineEdit::Password);
            m_toggleBtn->setText(QString::fromUtf8("\xE2\x97\x8F")); // "◉"
            m_toggleBtn->setToolTip(tr("Show password"));
        }
    });
}

void PasswordEdit::resizeEvent(QResizeEvent *e)
{
    QLineEdit::resizeEvent(e);
    int x = width() - m_toggleBtn->width() - 4;
    int y = (height() - m_toggleBtn->height()) / 2;
    m_toggleBtn->move(x, y);
}

void PasswordEdit::showAlertMessage(const QString &msg)
{
    Q_UNUSED(msg);
    // Alert is handled by AuthDialog's error label
}

void PasswordEdit::setAlert(bool alert)
{
    if (alert) {
        setStyleSheet("PasswordEdit { border: 1px solid red; }");
    } else {
        setStyleSheet("");
    }
}

void PasswordEdit::hideAlertMessage()
{
    setAlert(false);
}

void PasswordEdit::setCopyEnabled(bool enabled)
{
    Q_UNUSED(enabled);
}

void PasswordEdit::setCutEnabled(bool enabled)
{
    Q_UNUSED(enabled);
}

QLineEdit *PasswordEdit::lineEdit() const
{
    return const_cast<PasswordEdit *>(this);
}

// ─── AuthDialog ──────────────────────────────────────────────────────────────

AuthDialog::AuthDialog(const QString &message,
                       const QString &iconName)
    : QDialog(nullptr)
    , m_message(message)
    , m_iconName(iconName)
    , m_adminsCombo(new QComboBox(this))
    , m_passwordInput(new PasswordEdit(this))
    , m_numTries(0)
    , m_lockLimitTryNum(getLockLimitTryNum())
    , m_authStatus(AuthStatus::None)
    , m_errorLabel(nullptr)
    , m_confirmBtn(nullptr)
{
    initUI();

    setlocale(LC_ALL, "");

    qDebug() << "lock limit: " << m_lockLimitTryNum;

    connect(m_adminsCombo, static_cast<void (QComboBox::*)(int)>(&QComboBox::currentIndexChanged),
            this, &AuthDialog::on_userCB_currentIndexChanged);
}

AuthDialog::~AuthDialog()
{
}

void AuthDialog::setError(const QString &error, bool alertImmediately)
{
    // dgetText workaround
    QString dgetText = "";
    if ("Finger moved too fast, please do not lift until prompted" == error) {
        dgetText = tr("Finger moved too fast, please do not lift until prompted");
    } else if ("Verification failed, 2 chances left" == error) {
        dgetText = tr("Verification failed, two chances left");
    } else {
        dgetText = QString(dgettext("deepin-authentication", error.toUtf8()));
    }
    m_errorMsg = dgetText;
    if (alertImmediately) {
        if (m_errorLabel) {
            m_errorLabel->setText(m_errorMsg);
            m_errorLabel->show();
        }
    }
}

void AuthDialog::setAuthInfo(const QString &info)
{
    m_passwordInput->setPlaceholderText(info);
    if ("Password" == info) {
        m_passwordInput->setFocus();
    }
    if (m_confirmBtn) {
        m_confirmBtn->setText(tr("Confirm", "button"));
        m_confirmBtn->setAccessibleName("Confirm");
    }
    update();
}

void AuthDialog::addOptions(QButtonGroup *bg)
{
    QList<QAbstractButton *> btns = bg->buttons();
    // Options are not needed for basic password auth;
    // kept as stub for extension compatibility.
    Q_UNUSED(btns);
}

bool AuthDialog::hasSecurityHighLever(QString userName)
{
    Q_UNUSED(userName);
    return false;
}

bool AuthDialog::hasOpenSecurity()
{
    return false;
}

void AuthDialog::createUserCB(const PolkitQt1::Identity::List &identities)
{
    m_adminsCombo->clear();

    for (const PolkitQt1::Identity &identity : identities) {
        if (!identity.isValid()) continue;

        QString username = identity.toString().remove("unix-user:");
        QString fullname = UsersManager::instance()->getFullName(username);
        QString displayName = fullname.isEmpty() ? username : fullname;

        if (username == qgetenv("USER"))
            m_adminsCombo->insertItem(0, displayName, identity.toString());
        else
            m_adminsCombo->addItem(displayName, identity.toString());
    }

    if (m_adminsCombo->count() > 0) {
        m_adminsCombo->setCurrentIndex(0);
    } else {
        qWarning() << "ERROR, no valid user";
    }
    m_adminsCombo->show();
}

bool AuthDialog::passwordIsExpired(PolkitQt1::Identity identity)
{
    QDBusInterface accounts("org.deepin.dde.Accounts1",
                            "/org/deepin/dde/Accounts1",
                            "org.deepin.dde.Accounts1",
                            QDBusConnection::systemBus());
    QDBusReply<QString> reply = accounts.call("FindUserById",
        QString::number(identity.toUnixUserIdentity().uid()));
    if (reply.isValid()) {
        const QString path = reply.value();
        if (!path.isEmpty()) {
            QDBusInterface accounts_user("org.deepin.dde.Accounts1", path,
                "org.deepin.dde.Accounts1.User", QDBusConnection::systemBus());
            QDBusReply<bool> expiredReply = accounts_user.call("IsPasswordExpired");
            if (expiredReply.isValid())
                return expiredReply.value();
        }
    }
    return false;
}

PolkitQt1::Identity AuthDialog::selectedAdminUser() const
{
    if (m_adminsCombo->currentIndex() == -1)
        return PolkitQt1::Identity();

    const QString &id = m_adminsCombo->currentData().toString();
    if (id.isEmpty())
        return PolkitQt1::Identity();

    return PolkitQt1::Identity::fromString(id);
}

QString AuthDialog::password() const
{
    return m_passwordInput->text();
}

int AuthDialog::getLockLimitTryNum()
{
    const QString path = "/usr/share/dde-session-shell/dde-session-shell.conf";
    int count = 5;
    QFile file(path);
    if (!file.exists()) {
        return count;
    }

    QSettings settings(path, QSettings::IniFormat);
    settings.beginGroup("LockTime");
    count = settings.value("lockLimitTryNum").toInt();
    settings.endGroup();
    return count;
}

void AuthDialog::on_userCB_currentIndexChanged(int /*index*/)
{
    PolkitQt1::Identity identity = selectedAdminUser();

    m_passwordInput->clear();
    m_passwordInput->setAlert(false);
    m_passwordInput->setPlaceholderText("");
    m_errorMsg.clear();
    m_numTries = 0;

    if (!identity.isValid()) {
        m_passwordInput->setEnabled(false);
    } else {
        if (passwordIsExpired(identity)) {
            m_passwordInput->setEnabled(false);
            m_passwordInput->setPlaceholderText(tr("Unavailable"));
            setError(tr("The password of this user has expired. "
                        "Please authenticate using another user account or "
                        "change the password and try again."), true);
        } else {
            m_passwordInput->setEnabled(true);
            m_passwordInput->hideAlertMessage();
            emit adminUserSelected(identity);
            m_passwordInput->setFocus();
        }
    }
}

void AuthDialog::lock()
{
    m_passwordInput->setEnabled(false);
    if (m_confirmBtn)
        m_confirmBtn->setEnabled(false);
}

void AuthDialog::authenticationFailure(bool &isLock)
{
    m_numTries++;
    if (!isLock) {
        if (m_lockLimitTryNum <= m_numTries) {
            isLock = true;
        }
    }

    if (m_errorMsg.isEmpty()) {
        qDebug() << "authentication failed, error message is empty, set error message by agent.";
        if (isLock) {
            setError(tr("Locked, please try again later"));
        } else {
            setError(tr("Wrong password"));
        }
    }

    if (m_errorLabel)
        m_errorLabel->setText(m_errorMsg);

    m_passwordInput->setEnabled(true);
    m_passwordInput->setAlert(true);
    m_passwordInput->setFocus();
    m_passwordInput->selectAll();

    const bool enable = (m_authStatus != Authenticating
                         && m_authStatus != None
                         && !m_passwordInput->text().isEmpty());
    if (m_confirmBtn)
        m_confirmBtn->setEnabled(enable);

    if (isLock) {
        lock();
    }
    activateWindow();
}

bool AuthDialog::event(QEvent *event)
{
    if (event->type() == QEvent::Enter) {
        activateWindow();
        m_passwordInput->setFocus();
    }
    return QDialog::event(event);
}

void AuthDialog::initUI()
{
    // Wayland: try to stay on top; can't use DLayerShellWindow without Dtk6
    setWindowFlags(windowFlags() | Qt::WindowStaysOnTopHint | Qt::Tool);
    setWindowFlag(Qt::BypassWindowManagerHint, true);

    setMinimumWidth(380);

    QVBoxLayout *mainLayout = new QVBoxLayout(this);
    mainLayout->setSpacing(10);
    mainLayout->setContentsMargins(20, 20, 20, 20);

    // Title
    QLabel *titleLabel = new QLabel(m_message, this);
    titleLabel->setWordWrap(true);
    titleLabel->setAlignment(Qt::AlignCenter);
    {
        QFont f = titleLabel->font();
        f.setPointSize(12);
        f.setBold(true);
        titleLabel->setFont(f);
    }
    mainLayout->addWidget(titleLabel);

    // Icon
    QLabel *iconLabel = new QLabel(this);
    iconLabel->setAlignment(Qt::AlignCenter);
    {
        QPixmap icon;
        const qreal dpr = devicePixelRatioF();
        if (!m_iconName.isEmpty() && QIcon::hasThemeIcon(m_iconName)) {
            icon = QIcon::fromTheme(m_iconName).pixmap(
                static_cast<int>(48 * dpr), static_cast<int>(48 * dpr));
        } else {
            icon = QPixmap(":/images/default.svg");
        }
        icon.setDevicePixelRatio(dpr);
        iconLabel->setPixmap(icon);
    }
    mainLayout->addWidget(iconLabel);

    // Error label (hidden until setError is called)
    m_errorLabel = new QLabel(this);
    m_errorLabel->setWordWrap(true);
    m_errorLabel->setStyleSheet("QLabel { color: red; }");
    m_errorLabel->hide();
    mainLayout->addWidget(m_errorLabel);

    // Admin user combo
    m_adminsCombo->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
    m_adminsCombo->hide();
    mainLayout->addWidget(m_adminsCombo);

    // Password input
    m_passwordInput->setCopyEnabled(false);
    m_passwordInput->setCutEnabled(false);
    m_passwordInput->setAccessibleName("PasswordInput");
    mainLayout->addWidget(m_passwordInput);

    // Buttons
    QHBoxLayout *btnLayout = new QHBoxLayout();
    btnLayout->addStretch();

    QPushButton *cancelBtn = new QPushButton(tr("Cancel", "button"), this);
    cancelBtn->setAccessibleName("Cancel");
    m_confirmBtn = new QPushButton(tr("Confirm", "button"), this);
    m_confirmBtn->setDefault(true);
    m_confirmBtn->setEnabled(false);
    m_confirmBtn->setAccessibleName("Confirm");

    btnLayout->addWidget(cancelBtn);
    btnLayout->addWidget(m_confirmBtn);
    mainLayout->addLayout(btnLayout);

    m_adminsCombo->setAccessibleName("AdminUsers");

    // Wire signals
    connect(cancelBtn, &QPushButton::clicked, this, &QDialog::reject);
    connect(m_confirmBtn, &QPushButton::clicked, this, &QDialog::accept);
    connect(m_passwordInput, &QLineEdit::textChanged, this, [this](const QString &text) {
        if (m_confirmBtn) {
            m_confirmBtn->setEnabled(
                m_authStatus != Authenticating
                && m_authStatus != None
                && text.length() > 0);
        }
        if (text.length() > 0) {
            m_passwordInput->setAlert(false);
            m_errorMsg.clear();
        }
    });

    setWindowTitle(tr("Authentication Required"));
}

void AuthDialog::setInAuth(AuthStatus authStatus)
{
    m_authStatus = authStatus;
    const bool enable = (authStatus != Authenticating
                         && authStatus != None
                         && !m_passwordInput->text().isEmpty());
    if (m_confirmBtn)
        m_confirmBtn->setEnabled(enable);
}
