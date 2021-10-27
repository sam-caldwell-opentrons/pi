.PHONY:=images

images:
	@echo "Make raspberry pi images"
	@mkdir build &> /dev/null || true
	@packer build ./src/raspbian.pkr.hcl
