FROM fedora

RUN	yum update -y
RUN yum install -y autoconf automake doxygen graphviz mod_dav_svn subversion git gcc gcc-c++ autoconf automake make openssl
RUN yum install -y libmicrohttpd-devel jansson-devel libnice-devel openssl-devel libsrtp-devel sofia-sip-devel glib-devel opus-devel libogg-devel libini_config-devel pkgconfig gengetopt libtool

# problem compiling usrsctp
# RUN	svn co http://sctp-refimpl.googlecode.com/svn/trunk/KERN/usrsctp /usr/lib/usrsctp
# RUN	cd /usr/lib/usrsctp && ./bootstrap && ./configure --prefix=/usr --libdir=/usr/lib64
# RUN	cd /usr/lib/usrsctp && make && make install

RUN	git clone https://github.com/meetecho/janus-gateway.git /usr/lib/janus-gateway
RUN	cd /usr/lib/janus-gateway && sh autogen.sh && \
	./configure --prefix= --disable-websockets --disable-rabbitmq --disable-data-channels && \
	make && make install && make configs

EXPOSE 7088
EXPOSE 8080

RUN openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:1024 -keyout /usr/lib/janus-gateway/certs/privateKey.key -out /usr/lib/janus-gateway/certs/certificate.crt -subj '/C=US/ST=Florida/L=Fort Lauderdale/O=MrGossett/OU=Janus/CN=MrGossett'

# currently has a problem with the certs in /usr/lib/janus-gateway/certs/. works fine if run from within the container
CMD	/bin/janus --port=8080 -c /usr/lib/janus-gateway/certs/certificate.crt -k /usr/lib/janus-gateway/certs/privateKey.key --stun-server=global.stun.twilio.com:3478 --debug-level=3 --debug-timestamps