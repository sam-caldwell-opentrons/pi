.PHONY:=adhoc_runner

adhoc_runner:
	(\
		cd src/adhoc_runner || exit 1;\
		go test; \
	  	GOOS=linux GOARCH=arm64 go build -o ../../build/adhoc_runner main.go;\
	)
