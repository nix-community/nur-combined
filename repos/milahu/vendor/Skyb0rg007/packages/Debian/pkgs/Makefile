
ARCH := amd64

DPKG_VERSION = $(shell dpkg-parsechangelog --file $(1)/debian/changelog --show-field Version)
DPKG_SRCVERSION = $(word 1,$(subst -, ,$(1)))

SKYENET_ARCHIVE_KEYRING_VERSION = $(call DPKG_VERSION,skyenet-archive-keyring)
SKYENET_ARCHIVE_KEYRING_SRCVERSION = $(call DPKG_SRCVERSION,$(SKYENET_ARCHIVE_KEYRING_VERSION))

GORM_PAGINATOR_VERSION = $(call DPKG_VERSION,golang-github-biezhi-gorm-paginator-pagination)
GORM_PAGINATOR_SRCVERSION = $(call DPKG_SRCVERSION,$(GORM_PAGINATOR_VERSION))

PWNAGOTCHI_VERSION = $(call DPKG_VERSION,pwnagotchi)
PWNAGOTCHI_SRCVERSION = $(call DPKG_SRCVERSION,$(PWNAGOTCHI_VERSION))

PWNGRID_VERSION = $(call DPKG_VERSION,pwngrid)
PWNGRID_SRCVERSION = $(call DPKG_SRCVERSION,$(PWNGRID_VERSION))

SMLNJ_VERSION = $(call DPKG_VERSION,smlnj)
SMLNJ_SRCVERSION = $(call DPKG_SRCVERSION,$(SMLNJ_VERSION))

.DEFAULT: info
.PHONY:

info:
	@echo "skyenet-archive-keyring $(SKYENET_ARCHIVE_KEYRING_VERSION)"
	@echo "gorm-paginator $(GORM_PAGINATOR_VERSION)"
	@echo "pwnagotchi $(PWNAGOTCHI_VERSION)"
	@echo "pwngrid $(PWNGRID_VERSION)"
	@echo "smlnj $(SMLNJ_VERSION)"

golang-github-biezhi-gorm-paginator-pagination_0.0.2.orig.tar.gz: \
	golang-github-biezhi-gorm-paginator-pagination/debian/watch
	uscan --force-download --download-current-version \
		--destdir=$(PWD) \
		--package=golang-github-biezhi-gorm-paginator-pagination \
		--watchfile=$< \
		--upstream-version=0.0.2

golang-github-biezhi-gorm-paginator-pagination_0.0.2-1.debian.tar.xz \
	golang-github-biezhi-gorm-paginator-pagination_0.0.2-1.dsc &: \
	golang-github-biezhi-gorm-paginator-pagination_0.0.2.orig.tar.gz \
	$(shell find golang-github-biezhi-gorm-paginator-pagination/debian -type f)
	dpkg-source -b golang-github-biezhi-gorm-paginator-pagination

golang-github-biezhi-gorm-paginator-pagination_0.0.2-1_amd64.build \
golang-github-biezhi-gorm-paginator-pagination_0.0.2-1_amd64.buildinfo \
golang-github-biezhi-gorm-paginator-pagination_0.0.2-1_amd64.changes \
golang-github-biezhi-gorm-paginator-pagination-dev_0.0.2-1_all.deb &: golang-github-biezhi-gorm-paginator-pagination_0.0.2-1.dsc
	sbuild $<

clean::
	$(RM) *.tar.gz *.tar.xz
	$(RM) *.build *.buildinfo *.changes
	$(RM) *.deb *.dsc

# skyenet-archive-keyring: $(BUILDDIR)/skyenet-archive-keyring_$(SKYENET_ARCHIVE_KEYRING_VERSION)_$(ARCH).changes
# gorm-paginator: $(BUILDDIR)/golang-github-biezhi-gorm-paginator-pagination_$(GORM_PAGINATOR_VERSION)_$(ARCH).changes
# pwnagotchi: $(BUILDDIR)/pwnagotchi_$(PWNAGOTCHI_VERSION)_$(ARCH).changes
# pwngrid: $(BUILDDIR)/pwngrid_$(PWNGRID_VERSION)_$(ARCH).changes
# smlnj: $(BUILDDIR)/smlnj_$(SMLNJ_VERSION)_$(ARCH).changes
#
# uscan = \
# 	$$(BUILDDIR)/$(1)_$(2).orig.tar.gz: $(1)/debian/watch | $$(BUILDDIR); \
# 		uscan --force-download --download-current-version \
# 			--destdir=$$(BUILDDIR) \
# 			--package=$(1) \
# 			--watchfile=$$< \
# 			--upstream-version=$(2)
#
# copysrc = \
# 	$$(BUILDDIR)/$(1)-$(2)/.touch: $$(BUILDDIR)/$(1)_$(2).orig.tar.gz $(wildcard $(1)/**/*) | $$(BUILDDIR); \
# 		rm -rf $$(@D); \
# 		mkdir -p $$(@D); \
# 		tar xf $$< -C $$(BUILDDIR); \
# 		cp -r $(1)/debian $$(@D); \
# 		touch $$@
#
# buildpackage = \
#    $$(BUILDDIR)/$(1)_$(2)_$$(ARCH).deb \
#    $$(BUILDDIR)/$(1)_$(2).dsc \
#    $$(BUILDDIR)/$(1)_$(2)_$$(ARCH).buildinfo \
#    $$(BUILDDIR)/$(1)_$(2)_$$(ARCH).changes &: $$(BUILDDIR)/$(1)-$(3)/.touch; \
# 	   dpkg-buildpackage --no-sign $$(<D)
#
# $(BUILDDIR)/skyenet-archive-keyring-$(SKYENET_ARCHIVE_KEYRING_SRCVERSION)/.touch: ./skyenet-archive-keyring | $(BUILDDIR)
# 	rm -rf $(@D)
# 	mkdir -p $(@D)
# 	cp -r skyenet-archive-keyring/* $(@D)
# 	touch $@
# $(eval $(call buildpackage,skyenet-archive-keyring,$(SKYENET_ARCHIVE_KEYRING_VERSION),$(SKYENET_ARCHIVE_KEYRING_SRCVERSION)))
#
# $(eval $(call uscan,smlnj,$(SMLNJ_SRCVERSION)))
# $(eval $(call copysrc,smlnj,$(SMLNJ_SRCVERSION)))
# $(eval $(call buildpackage,smlnj,$(SMLNJ_VERSION),$(SMLNJ_SRCVERSION)))
#
# $(eval $(call uscan,pwngrid,$(PWNGRID_SRCVERSION)))
# $(eval $(call copysrc,pwngrid,$(PWNGRID_SRCVERSION)))
# $(eval $(call buildpackage,pwngrid,$(PWNGRID_VERSION),$(PWNGRID_SRCVERSION)))
#
# $(eval $(call uscan,pwnagotchi,$(PWNAGOTCHI_SRCVERSION)))
# $(eval $(call copysrc,pwnagotchi,$(PWNAGOTCHI_SRCVERSION)))
# $(eval $(call buildpackage,pwnagotchi,$(PWNAGOTCHI_VERSION),$(PWNAGOTCHI_SRCVERSION)))
#
# $(BUILDDIR):
# 	mkdir -p $@

