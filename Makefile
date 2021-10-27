OPSYS=$(shell uname -s || windows)

include Makefile.d/*.mk

help:
	@echo ''
	@echo 'Packer Pi'
	@echo '(c) 2021 Sam Caldwell.  See LICENSE.md'
	@echo ''
	@echo 'setup - install the dependencies needed to run this image builder.'
	@echo 'clean - clean things.'
	@echo 'images - build images defined in the project.'
	@echo ''
