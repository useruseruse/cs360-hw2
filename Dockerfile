FROM alpine:latest

ENV TOMCAT_MAJOR=10 \
    TOMCAT_VERSION=10.1.7 \
    OPENJDK_VERISON=17 \
    CATALINA_HOME=/opt/tomcat \
    JAVA_OPTS=-Dspring.profiles.active=dev -Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true \
    CATALINA_OPTS="-Xms512M -Xmx1024M -server -XX:+UseParallelGC" \
    JAVA_HOME=/usr/lib/jvm/default-jvm

RUN apk add openjdk${OPENJDK_VERISON}

RUN apk -U upgrade --update && \
    apk add curl && \
    apk add ttf-dejavu

RUN mkdir -p /opt

RUN curl -jkSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME


RUN apk del curl && \
    rm -rf /tmp/* /var/cache/apk/*

RUN apk add chromium
RUN apk add chromium-chromedriver
RUN apk add python3 python3-dev py3-pip
RUN apk add gcc musl-dev libffi-dev
RUN pip3 install selenium pymysql

COPY config /usr/src/config
RUN mkdir -p /usr/src/python
RUN cp /usr/src/config/tester.py /usr/src/python
RUN cp /usr/src/config/*.jar /opt/tomcat/lib
RUN cp /usr/src/config/context.xml /opt/tomcat/conf
RUN cp /usr/src/config/server.xml /opt/tomcat/conf
RUN mkdir -p /opt/tomcat/webapps/ROOT/WEB-INF
RUN cp /usr/src/config/web.xml /opt/tomcat/webapps/ROOT/WEB-INF

ENTRYPOINT sh $CATALINA_HOME/bin/catalina.sh run

WORKDIR /usr/src/app