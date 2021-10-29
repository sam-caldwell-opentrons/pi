.PHONY:=clean

clean:
	@echo "Clean the build directory"
	@rm -rf ./build &> /dev/null || true
	@mkdir -p ./build
	@docker rmi -f plugin-builder:latest

deep_clean:
	@docker system prune -f --all