.PHONY:=images
images:
	@echo "Make raspberry pi images"
	docker run --privileged -it plugin-builder:local
