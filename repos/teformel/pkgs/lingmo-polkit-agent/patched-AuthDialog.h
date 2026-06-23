// SPDX-FileCopyrightText: 2017 - 2022 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef AUTHDIALOG_H
#define AUTHDIALOG_H

#include <QDialog>
#include <QLineEdit>
#include <QPushButton>
#include <QLabel>

#include <QWindow>
#include <QComboBox>

#include <PolkitQt1/Identity>
#include <PolkitQt1/ActionDescription>

namespace PolkitQt1 {
class Details;
}

class QVBoxLayout;

// Simple password input with show/hide toggle, replacing DPasswordEdit
class PasswordEdit : public QLineEdit
{
    Q_OBJECT
public:
    explicit PasswordEdit(QWidget *parent = nullptr);

    void showAlertMessage(const QString &msg);
    void setAlert(bool alert);
    void hideAlertMessage();

    void setCopyEnabled(bool enabled);
    void setCutEnabled(bool enabled);
    QLineEdit *lineEdit() const;

signals:
    void alertMessage(const QString &msg);

protected:
    void resizeEvent(QResizeEvent *e) override;

private:
    QPushButton *m_toggleBtn;
};

class AuthDialog : public QDialog
{
    Q_OBJECT
public:
    enum AuthMode {
        FingerPrint = 0,
        Password = 1
    };

    enum AuthStatus {
        None = -1,
        WaitingInput,
        Authenticating,
        Completed,
    };

    AuthDialog(const QString &message,
               const QString &iconName);
    ~AuthDialog();

    void setError(const QString &error, bool alertImmediately = false);
    void setRequest(const QString &request, bool requiresAdmin);
    void authenticationFailure(bool &isLock);
    void createUserCB(const PolkitQt1::Identity::List &identities);

    void setAuthInfo(const QString &info);

    void addOptions(QButtonGroup *bg);

    QString password() const;
    void lock();

    PolkitQt1::Identity selectedAdminUser() const;

    bool hasOpenSecurity();
    bool hasSecurityHighLever(QString userName);
    void setInAuth(AuthStatus authStatus);

signals:
    void adminUserSelected(PolkitQt1::Identity);
    void accepted();
    void rejected();

protected:
    bool event(QEvent *event) override;

private:
    void initUI();
    void setupUI(QVBoxLayout *layout);
    int getLockLimitTryNum();
    bool passwordIsExpired(PolkitQt1::Identity identity);

private slots:
    void on_userCB_currentIndexChanged(int index);

private:
    QString m_appname;
    QString m_message;
    QString m_iconName;

    QComboBox *m_adminsCombo;
    PasswordEdit *m_passwordInput;

    int m_numTries;
    int m_lockLimitTryNum;

    void showErrorTip();

    QString m_errorMsg;
    AuthStatus m_authStatus;

    QLabel *m_errorLabel;
    QList<QPushButton*> m_buttons;
    QPushButton *m_confirmBtn;
};
#endif // AUTHDIALOG_H
