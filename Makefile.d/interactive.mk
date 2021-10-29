.PHONY:=interactive

CURRENT_DIR=$(shell pwd)
interactive:
	@echo "start build container in interactive shell mode."
	@docker run --privileged \
			   -v $(CURRENT_DIR)/build:/output \
			   --entrypoint '' \
			   -it plugin-builder:local /bin/bash
