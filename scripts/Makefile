MKFILES_DIR=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
EDAPACK_VERILATOR_DIR=$(abspath $(MKFILES_DIR)/..)
PACKAGES_DIR=$(EDAPACK_VERILATOR_DIR)/packages
BUILD_DIR=$(EDAPACK_VERILATOR_DIR)/build
GITHUB=https://github.com
EDAPACK_BUILD_URL=https://github.com/EDAPack/edapack-build

include $(EDAPACK_VERILATOR_DIR)/etc/package.info

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
PACKAGE=$(BUILD_DIR)/verilator-$(platform)-$(version).tar.gz

all : $(PACKAGE)

$(PACKAGE) : \
		$(BUILD_DIR)/verilator.d \
		$(EDAPACK_VERILATOR_PREFIX)/etc/package.info \
		$(EDAPACK_VERILATOR_PREFIX)/etc/install.py
	$(Q)cd $(EDAPACK_VERILATOR_PREFIX) ; tar czf $@ *

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

$(EDAPACK_VERILATOR_PREFIX)/etc/package.info : \
		$(EDAPACK_VERILATOR_DIR)/etc/package.info
	$(Q)mkdir -p $(EDAPACK_VERILATOR_PREFIX)/etc
	$(Q)cp $^ $@

$(EDAPACK_VERILATOR_PREFIX)/etc/install.py : $(PACKAGES_DIR)/install.py
	$(Q)mkdir -p $(EDAPACK_VERILATOR_PREFIX)/etc
	$(Q)cp $^ $@

release : $(PACKAGE) $(PACKAGES_DIR)/upload.py
	$(Q)python3 $(PACKAGES_DIR)/upload.py \
		--org EDAPack --repo verilator \
		--key $(GITHUB_API_TOKEN) --version $(version) \
		$(BUILD_DIR)/verilator-$(platform)-$(version).tar.gz

$(PACKAGES_DIR)/install.py :
	$(Q)mkdir -p $(PACKAGES_DIR)
	$(Q)$(WGET) -O $@ \
          $(EDAPACK_BUILD_URL)/raw/master/scripts/install.py || \
		(rm -f $@ ; exit 1)

$(PACKAGES_DIR)/upload.py :
	$(Q)mkdir -p $(PACKAGES_DIR)
	$(Q)$(WGET) -O $@ \
          $(EDAPACK_BUILD_URL)/raw/master/scripts/upload.py || \
		(rm -rf $@ ; exit 1)

clean :
	$(Q)rm -rf $(BUILD_DIR)

clean-all :
	$(Q)rm -rf $(BUILD_DIR) $(PACKAGES_DIR)
	
