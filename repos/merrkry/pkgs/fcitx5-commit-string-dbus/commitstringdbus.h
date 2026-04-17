#ifndef FCITX5_COMMITSTRINGDBUS_H
#define FCITX5_COMMITSTRINGDBUS_H

#include <memory>
#include <string>

#include <dbus_public.h>
#include <fcitx-utils/dbus/bus.h>
#include <fcitx-utils/dbus/objectvtable.h>
#include <fcitx/addonfactory.h>
#include <fcitx/addoninstance.h>
#include <fcitx/addonmanager.h>
#include <fcitx/instance.h>

class CommitStringBackend;

class CommitStringDBus final : public fcitx::AddonInstance {
public:
    explicit CommitStringDBus(fcitx::Instance *instance);
    ~CommitStringDBus() override;

    void commitString(const std::string &text);

private:
    void initDBusInterface();

    FCITX_ADDON_DEPENDENCY_LOADER(dbus, instance_->addonManager());

    fcitx::Instance *instance_;
    fcitx::dbus::Bus *bus_ = nullptr;
    std::unique_ptr<CommitStringBackend> backend_;
};

class CommitStringDBusFactory : public fcitx::AddonFactory {
public:
    fcitx::AddonInstance *create(fcitx::AddonManager *manager) override;
};

#endif
