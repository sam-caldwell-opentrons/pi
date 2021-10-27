.PHONY:=setup-packer-plugin

setup-packer-plugin:
	@echo "Install packer-builder-arm plugin"
	@(\
		set -e;\
		cd build || exit 1;\
		mkdir plugin;\
		cd plugin;\
		git clone https://github.com/mkaczanowski/packer-builder-arm;\
		cd packer-builder-arm;\
		go mod download;\
		go build;\
		mkdir $${HOME}/.packer.d/plugins/ &> /dev/null || true; \
		mv packer-builder-arm $${HOME}/.packer.d/plugins/; \
	)

