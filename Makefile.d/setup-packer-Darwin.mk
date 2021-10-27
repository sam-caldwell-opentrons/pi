.PHONY:=setup-packer-Darwin

setup-packer-Darwin:
	@echo "Install packer to darwin"
	@command -v brew || {\
		echo "Brew must be installed.";\
		exit 1;\
	}
	@brew tap hashicorp/tap
	@brew install hashicorp/tap/packer
	@brew install qemu
	@brew install git
	@brew install unzip
	@brew install e2fsprogs
	@brew install dosfstools
	@brew install bsdtar
	@brew install vagrant
	@vagrant plugin install vagrant-scp