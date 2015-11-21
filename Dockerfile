FROM my-jessie:latest
MAINTAINER Josh Cox <josh 'at' webhosting.coop>

RUN apt-get -y update
# RUN apt-get -y install python-software-properties curl build-essential libxml2-dev libxslt-dev git ruby ruby-dev ca-certificates sudo net-tools vim wget
RUN apt-get -y dist-upgrade

RUN apt-get -y install locales \
libcurl4-openssl-dev \
xvfb \
wget \
x11vnc \
net-tools \
libboost-all-dev \
libboost-system-dev libboost-filesystem-dev libboost-chrono-dev \
libboost-program-options-dev libboost-test-dev libboost-thread-dev \
libminiupnpc-dev \
libzmq3-dev \
libqrencode-dev \
git \
libdb-dev libdb++-dev \
libleveldb-dev libleveldb-cil-dev \
build-essential libtool autotools-dev autoconf pkg-config libssl-dev libevent-dev bsdmainutils \
libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler


# RUN echo 'en_US.ISO-8859-15 ISO-8859-15'>>/etc/locale.gen
# RUN echo 'en_US ISO-8859-1'>>/etc/locale.gen
RUN echo 'en_US.UTF-8 UTF-8'>>/etc/locale.gen
RUN locale-gen
ENV LANG en_US.UTF-8

ENV HOSTUID 1000
RUN useradd --uid $HOSTUID -m -s /bin/bash wallet
RUN usermod -a -G video,audio,tty wallet

USER wallet
WORKDIR /home/wallet

# let's clone and build from source instead
# RUN wget -c https://chain.fair-coin.org/download/faircoin-linux-v1.5.1.tar.bz2

# clone from github
#RUN git clone https://github.com/FairCoinTeam/fair-coin.git
RUN git clone https://github.com/namecoin/namecoin-core.git
# build from source
#RUN cd fair-coin && ./autogen.sh && ./configure --prefix=/usr --disable-maintainer-mode --with-incompatible-bdb --disable-tests && make && strip src/qt/FairCoin-qt && strip src/FairCoind
#RUN cd namecoin-core && ./autogen.sh && ./configure --prefix=/usr --disable-maintainer-mode --with-incompatible-bdb --disable-tests && make && strip bitcoind
RUN cd namecoin-core && ./autogen.sh && ./configure --prefix=/usr --disable-maintainer-mode --with-incompatible-bdb --disable-tests && make


# start script for some root tidy stuff
ADD start.sh /home/wallet/start.sh
# start.sh should sudo -u wallet and call run.sh
ADD run.sh /home/wallet/run.sh

USER root
CMD ["/bin/bash", "/home/wallet/start.sh"]
