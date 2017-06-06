FROM ubuntu:16.04

MAINTAINER Jim Arnell <hirro@users.noreply.github.com>

ENV JMETER_VERSION 3.2
ENV JMETER_HOME /usr/local/apache-jmeter-${JMETER_VERSION}
ENV JMETER_BIN $JMETER_HOME/bin
ENV SERVER_PORT 1099
ENV CLIENT_PORT 60000
ENV IP 0.0.0.0

RUN apt-get -qq update && \
    apt-get -yqq install openjdk-8-jre-headless unzip && \
    apt-get -q clean && \
    rm -rf /var/lib/apt/lists/*

COPY dependencies /tmp/dependencies

RUN tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /usr/local && \
    unzip -oq "/tmp/dependencies/JMeterPlugins-*.zip" -d $JMETER_HOME && \
    cp /tmp/dependencies/*.jar $JMETER_HOME/lib && \
    cp /tmp/dependencies/*.properties $JMETER_BIN && \
    apt-get -yqq purge unzip && \
    apt-get -yqq autoremove && \
    rm -rf /tmp/dependencies

ENV PATH $PATH:$JMETER_BIN

WORKDIR $JMETER_HOME

EXPOSE 1099 60000

VOLUME /jmx /results

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["slave"]
