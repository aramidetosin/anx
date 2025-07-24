FROM debian:bullseye-slim
LABEL maintainer="Steven Barth <stbarth@cisco.com>"

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64
ENV PATH=$JAVA_HOME/bin:$PATH
ENV DEBIAN_FRONTEND=noninteractive

COPY anc /src/anc/
COPY explorer /src/explorer/
COPY grpc /src/grpc/
COPY pom.xml /src/

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
    openjdk-11-jdk-headless \
    jetty9 \
    maven && \
    mkdir -p /usr/share/man/man1 && \
    cd /src && \
    mvn package javadoc:javadoc && \
    cp /src/explorer/target/*.war /var/lib/jetty9/webapps/ROOT.war && \
    cp -a /src/anc/target/site/apidocs /var/lib/jetty9/webapps/ || true && \
    mkdir /usr/share/yangcache && \
    rm -rf /var/lib/jetty9/webapps/root && \
    cd / && rm -rf /src /root/.m2 && \
    apt-get remove -y openjdk-11-jdk-headless maven && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
EXPOSE 8080
CMD ["/usr/share/jetty9/bin/jetty.sh", "run"]
