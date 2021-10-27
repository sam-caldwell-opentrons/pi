.PHONY:=clean

clean:
	@echo "Clean the build directory"
	@rm -rf ./build &> /dev/null || true
	@mkdir -p ./build
