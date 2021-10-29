.PHONY:=setup

setup:
	@echo "Setup environment."
	@command -v docker || {\
  		echo "docker must be installed to use this project.";\
  		echo 42;\
  	}
