#include "commitstringdbus.h"

#include <fcitx-utils/log.h>

namespace {

constexpr char kServiceName[] = "org.fcitx.Fcitx5.CommitString";
constexpr char kObjectPath[] = "/commitstring";
constexpr char kInterfaceName[] = "org.fcitx.Fcitx5.CommitString";

} // namespace

class CommitStringBackend : public fcitx::dbus::ObjectVTable<CommitStringBackend> {
public:
    explicit CommitStringBackend(CommitStringDBus &parent) : parent_(parent) {}

    void commitString(const std::string &text) { parent_.commitString(text); }

private:
    FCITX_OBJECT_VTABLE_METHOD(commitString, "CommitString", "s", "");

    CommitStringDBus &parent_;
};

CommitStringDBus::CommitStringDBus(fcitx::Instance *instance)
    : instance_(instance), bus_(dbus()->call<fcitx::IDBusModule::bus>()) {
    initDBusInterface();
}

CommitStringDBus::~CommitStringDBus() = default;

void CommitStringDBus::initDBusInterface() {
    backend_ = std::make_unique<CommitStringBackend>(*this);
    bus_->addObjectVTable(kObjectPath, kInterfaceName, *backend_);
    bus_->requestName(
        kServiceName,
        fcitx::Flags<fcitx::dbus::RequestNameFlag>{
            fcitx::dbus::RequestNameFlag::ReplaceExisting,
            fcitx::dbus::RequestNameFlag::Queue,
        });
    bus_->flush();
}

void CommitStringDBus::commitString(const std::string &text) {
    auto *inputContext = instance_->mostRecentInputContext();
    if (!inputContext) {
        FCITX_WARN() << "commitstringdbus: no active input context";
        return;
    }

    inputContext->commitString(text);
}

fcitx::AddonInstance *CommitStringDBusFactory::create(
    fcitx::AddonManager *manager) {
    return new CommitStringDBus(manager->instance());
}

FCITX_ADDON_FACTORY_V2(commitstringdbus, CommitStringDBusFactory);
