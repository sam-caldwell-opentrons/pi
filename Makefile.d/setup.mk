.PHONY:=setup

setup: clean
	@echo "Setup environment."
	echo "OPSYS: $(OPSYS)"
	@command -v packer || (\
		echo "packer needs to be installed...";\
		make setup-packer-$(OPSYS);\
	)
	@command -v packer --version || {\
		echo "packer install failed.";\
		exit 1;\
	}
	make setup-packer-plugin
