setup-packer-plugin:
	@echo "Install packer-builder-arm plugin"
	@(\
		set -e;\
		cd build || exit 1;\
		mkdir plugin || true;\
		cd plugin;\
		[[ ! -d packer-builder-arm ]] && git clone $(PACKER_PLUGIN_REPO);\
		cd packer-builder-arm;\
		go mod download;\
		go build;\
		echo "create $${HOME}/.packer.d/plugins/"; \
		mkdir -p $${HOME}/.packer.d/plugins/ &> /dev/null || true; \
		mv ./packer-builder-arm $${HOME}/.packer.d/plugins/; \
		echo "packer-builder-arm built and installed."; \
	)

