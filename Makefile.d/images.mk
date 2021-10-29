.PHONY:=images
images:
	@echo "Make raspberry pi images"
	docker run --privileged \
			   -v $(CURRENT_DIR)/build:/output \
			   -it plugin-builder:local
