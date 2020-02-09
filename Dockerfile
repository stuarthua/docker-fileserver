FROM lsiobase/nginx:3.11

# set label
LABEL maintainer="stuarthua"

# package versions
ARG DIRECTORYLISTER_RELEASE

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache  \
	curl \
	memcached \
	php7-memcached \
	php7-tidy \
	tar && \
 echo "**** configure php-fpm ****" && \
 sed -i 's/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf && \
 echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf && \
 echo "**** fetch directorylister ****" && \
 mkdir -p\
	/data && \
 if [ -z ${DIRECTORYLISTER_RELEASE+x} ]; then \
	DIRECTORYLISTER_RELEASE=$(curl -sX GET "https://api.github.com/repos/stuarthua/directorylister/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/directorylister.tar.gz -L \
	"https://github.com/stuarthua/directorylister/archive/${DIRECTORYLISTER_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/directorylister.tar.gz -C \
	/data/ --strip-components=1 && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /data /config
