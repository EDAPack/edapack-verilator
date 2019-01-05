MKFILES_DIR=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
EDAPACK_VERILATOR_DIR=$(abspath $(MKFILES_DIR)/..)
PACKAGES_DIR=$(EDAPACK_VERILATOR_DIR)/packages
BUILD_DIR=$(EDAPACK_VERILATOR_DIR)/build

include $(EDAPACK_VERILATOR_DIR)/etc/edapack-verilator.info

ifeq (true,$(VERBOSE))
Q=
WGET=wget
UNTARGZ=tar xvzf
else
Q=@
WGET=wget -q
UNTARGZ=tar xzf
endif

uname_o:=$(shell uname -o)

ifeq (Linux,$(uname_o))
platform=linux_x86_64
else
ifeq (GNU/Linux,$(uname_o))
platform=linux_x86_64
else
platform=unknown
endif
endif

VERILATOR_DIR=verilator-$(version)
VERILATOR_TGZ=$(VERILATOR_DIR).tgz
VERILATOR_URL=https://www.veripool.org/ftp/$(VERILATOR_TGZ)

EDAPACK_VERILATOR_PREFIX=$(BUILD_DIR)/verilator/verilator

all : edapack-verilator

edapack-verilator : $(BUILD_DIR)/verilator-$(platform)-$(version).tar.gz

$(BUILD_DIR)/verilator-$(platform)-$(version).tar.gz : $(BUILD_DIR)/verilator.d
	$(Q)cd $(BUILD_DIR)/verilator ; tar czf $@ verilator

$(BUILD_DIR)/verilator.d : $(PACKAGES_DIR)/$(VERILATOR_TGZ)
	$(Q)rm -rf $(BUILD_DIR)/verilator
	$(Q)mkdir -p $(BUILD_DIR)/verilator
	$(Q)cd $(BUILD_DIR)/verilator ; $(UNTARGZ) $^
	$(Q)cd $(BUILD_DIR)/verilator/$(VERILATOR_DIR) ; \
		patch -p1 < $(EDAPACK_VERILATOR_DIR)/scripts/verilator.patch
	$(Q)cd $(BUILD_DIR)/verilator/$(VERILATOR_DIR) ; \
		export CXXFLAGS="-O3"; \
		./configure --prefix=$(EDAPACK_VERILATOR_PREFIX) \
			--enable-prec11 
	$(Q)cd $(BUILD_DIR)/verilator/$(VERILATOR_DIR) ; \
		$(MAKE) CXXFLAGS="-O3"
	$(Q)cd $(BUILD_DIR)/verilator/$(VERILATOR_DIR) ; $(MAKE) install
	$(Q)cp -r $(EDAPACK_VERILATOR_DIR)/smoketest $(EDAPACK_VERILATOR_PREFIX)
	$(Q)chmod +x $(EDAPACK_VERILATOR_PREFIX)/smoketest/runit.sh
	$(Q)touch $@

$(PACKAGES_DIR)/$(VERILATOR_TGZ) :
	$(Q)if test ! -d $(PACKAGES_DIR); then mkdir -p $(PACKAGES_DIR); fi
	$(Q)$(WGET) -O $@ $(VERILATOR_URL)

release : edapack-verilator
	$(Q)$(EDAPACK_VERILATOR_DIR)/scripts/upload.py \
		--org EDAPack --repo edapack-verilator \
		--key $(GITHUB_API_TOKEN) --version $(version) \
		$(BUILD_DIR)/verilator-$(platform)-$(version).tar.gz

clean :
	$(Q)rm -rf $(BUILD_DIR)

clean-all :
	$(Q)rm -rf $(BUILD_DIR) $(PACKAGES_DIR)
	
