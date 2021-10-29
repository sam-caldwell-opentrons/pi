.PHONY:=interactive

interactive:
	@echo "start build container in interactive shell mode."
	docker run --privileged --entrypoint '' -it plugin-builder:local /bin/bash
