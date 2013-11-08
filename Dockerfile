FROM ubuntu

# Get the latest Ubuntu packages.
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

# Install prerequisites:
RUN apt-get install -y wget python-software-properties software-properties-common

# Add the Java PPA:
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update

# This bit of magic makes the Java installer not ask us to accept the license:
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

# Install Java:
RUN apt-get install -y oracle-java7-installer

# Configure the Java environment:
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle
ENV PATH $PATH:$JAVA_HOME/bin

RUN wget https://download.elasticsearch.org/logstash/logstash/logstash-1.2.2-flatjar.jar

ADD logstash.conf logstash.conf

EXPOSE 9200
EXPOSE 9300
EXPOSE 9301
EXPOSE 9302
EXPOSE 9292

# Expose the Syslog UDP port.
EXPOSE 514/udp

ENTRYPOINT ["/usr/lib/jvm/java-7-oracle/bin/java", "-jar", "logstash-1.2.2-flatjar.jar", "agent", "-v", "-f", "logstash.conf", "--", "web"]
