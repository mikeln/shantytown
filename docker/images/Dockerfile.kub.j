#
#    Smaller Oracle Java (SErver) JRE base container
#
#    For use when openJava is not appropriate.
#    Side Load directly from Oracle...only way to just get a JRE.
#    (vs Oracle Install package which installs the bloated JDK instead).
#
FROM debian:wheezy
MAINTAINER Mikel Nelson <mikel.n@samsung.com>
#
#============================================
# Do all installs in one RUN command.  This is important 
# so any removal/cleanup will occur before the layer is 
# committed to the image.
#
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
    && DEBIAN_FRONTEND=noninteractive apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    wget \
    sudo \
    vim-tiny \
# Add Oracle Server JRE via side laod
    && wget --no-check-certificate -O /tmp/server-jre-7u80-linux-x64.tar.gz --header "Cookie: oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/7u80-b15/server-jre-7u80-linux-x64.tar.gz \
    && echo "366a145fb3a185264b51555546ce2f87  /tmp/server-jre-7u80-linux-x64.tar.gz" | md5sum -c >/dev/null 2>&1 || echo "ERROR: Java Download MD5SUM Mismatch" \
    && tar xzf /tmp/server-jre-7u80-linux-x64.tar.gz \
    && mkdir -p /usr/lib/jvm/java-7-oracle  \
    && mv jdk1.7.0_80/ /usr/lib/jvm/java-7-oracle/server-jre \
    && chown root:root -R /usr/lib/jvm/java-7-oracle \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-7-oracle/server-jre/bin/java 1 \
    && update-alternatives --set java /usr/lib/jvm/java-7-oracle/server-jre/bin/java \
#
# add any other pacakges that require Java JRE here
#   && DEBIAN_FRONTEND=noninteractive apt-get install -y \
#   <package 1> \
#   <package 2> \
#
# remove any packages that were needed for install but not needed in the final image
#
    && DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge wget \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
#
# remove all the temporary package manager files 
#
    && DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
# Done with package installs
#============================================
#
# Do file COPY here (do NOT use ADD unless explicitly necessary)
#
#COPY cassandra.yaml /etc/cassandra/cassandra.yaml
#COPY KubSeedProv-2.0-SNAPSHOT.jar /kubernetes-cassandra.jar
#COPY init.sh /usr/local/bin/cass-dock
#COPY shutdown.sh /usr/local/bin/cass-stop
#
# If additional RUN commands are needed, group them all into one command if possible
#
#RUN chmod 644 /kubernetes-cassandra.jar \
#    && chmod 755 /usr/local/bin/cass-dock \
#    && chmod 755 /usr/local/bin/cass-stop
#
# Port expose
#
#EXPOSE 7199 7000 7001 9160 9042
#EXPOSE 61620 61621 50031
USER root
CMD bash
