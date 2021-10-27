.PHONY:=setup-packer-Darwin

setup-packer-Darwin:
	@echo "Install packer to darwin"
	@command -v brew &>/dev/null || {\
		echo "Brew must be installed.";\
		exit 1;\
	}
	@command -v go version  &>/dev/null || brew install go
	@command -v packer &> /dev/null || {\
  		brew tap hashicorp/tap; \
  		brew install hashicorp/tap/packer; \
	}
	@command -v qemu &> /dev/null || brew install qemu
	@command -v git &> /dev/null || brew install git
	@command -v unzip &> /dev/null || brew install unzip
	@command -v e2fsprogs &> /dev/null || brew install e2fsprogs
	@command -v dosfstools &> /dev/null || brew install dosfstools
	@command -v bsdtar &> /dev/null || brew install bsdtar
	@command -v vagrant &> /dev/null || brew install vagrant
	@echo "============================="
	@echo "dependency installation done."
	@echo "============================="
