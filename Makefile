.PHONY: all help build run builddocker rundocker kill rm-image rm clean enter logs
all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: NAME TAG jessie builddocker

run: WALLETPATH rm build rundocker

jessie:
	sudo bash my-jessie.sh

rundocker:
	$(eval TMP := $(shell mktemp -d --suffix=DOCKERTMP))
	chmod 777 $(TMP)
	@docker run --name=`cat NAME` \
	--cidfile="cid" \
	-d \
	-v $(TMP):$(TMP) \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=':0' \
	--device /dev/dri \
	-v $(shell cat WALLETPATH):/home/wallet/.my-wallet \
	-v /var/run/docker.sock:/run/docker.sock \
	-v $(shell which docker):/bin/docker \
	-t `cat TAG`

builddocker:
	/usr/bin/time -v docker build -t `cat TAG` .

kill:
	-@docker kill `cat cid`

rm-image:
	-@docker rm `cat cid`
	-@rm cid

rm: kill rm-image

clean: cleanfiles rm

enter:
	docker exec -i -t `cat cid` /bin/bash

logs:
	docker logs -f `cat cid`

NAME:
	@while [ -z "$$NAME" ]; do \
		read -r -p "Enter the name you wish to associate with this container [NAME]: " NAME; echo "$$NAME">>NAME; cat NAME; \
	done ;

TAG:
	@while [ -z "$$TAG" ]; do \
		read -r -p "Enter the name you wish to associate with this container [TAG]: " TAG; echo "$$TAG">>TAG; cat TAG; \
	done ;

# will skip over this step if the name file is left from previous run 'make clean' to remove
WALLETPATH:
	@while [ -z "$$WALLETPATH" ]; do \
		read -r -p "Enter the path to the wallet folder you wish to sync with [WALLETPATH]: " WALLETPATH; echo "$$WALLETPATH">>WALLETPATH; cat WALLETPATH; \
	done ;
