.PHONY:=builder

builder: version
	@echo "Make build container"
	@rm -rf build
	@mkdir -p build
	(\
  		docker build -t plugin-builder:local -f src/Dockerfile .;\
  	)
