.PHONY:=setup-packer-Linux

setup-packer-Linux:
	@echo "Install packer to linux"
	@(\
		cd ./bin;\
		wget https://releases.hashicorp.com/packer/1.7.7/packer_1.7.7_linux_amd64.zip;\
		unzip packer_1.7.7_linux_amd64.zip;\
	)