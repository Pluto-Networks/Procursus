ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS := xh
XH_VERSION  := 0.13.0
DEB_XH_V    ?= $(XH_VERSION)

xh-setup: setup
	$(call GITHUB_ARCHIVE,ducaale,xh,$(XH_VERSION),v$(XH_VERSION))
	$(call EXTRACT_TAR,xh-$(XH_VERSION).tar.gz,xh-$(XH_VERSION),xh)

ifneq ($(wildcard $(BUILD_WORK)/xh/.build_complete),)
xh:
	@echo "Using previously built xh."
else
xh: xh-setup
	cd $(BUILD_WORK)/xh && $(DEFAULT_RUST_FLAGS) cargo build \
		--release \
		--all-features \
		--target=$(RUST_TARGET)
	$(INSTALL) -Dm755 $(BUILD_WORK)/xh/target/$(RUST_TARGET)/release/xh $(BUILD_STAGE)/xh/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin/xh
	$(call AFTER_BUILD)
endif

xh-package: xh-stage
	# xh.mk Package Structure
	rm -rf $(BUILD_DIST)/xh

	# xh.mk Prep xh
	cp -a $(BUILD_STAGE)/xh $(BUILD_DIST)

	# xh.mk Sign
	$(call SIGN,xh,general.xml)

	# xh.mk Make .debs
	$(call PACK,xh,DEB_XH_V)

	# xh.mk Build cleanup
	rm -rf $(BUILD_DIST)/xh

.PHONY: xh xh-package
