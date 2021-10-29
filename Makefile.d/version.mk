.PHONY:=version

VER_DATE:=$(shell date +%s)
VER_COMMIT:=$(shell git log -n1 | head -n1 | awk '{print $$2}')
version:
	echo "$(VER_DATE):$(VER_COMMIT)" > VERSION.txt