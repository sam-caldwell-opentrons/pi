.PHONY:=images
images:
	@echo "Make raspberry pi images"
	@docker run --privileged -it plugin-builder:latest
	#@docker run --privileged -v /dev:/dev -it plugin-builder:latest
