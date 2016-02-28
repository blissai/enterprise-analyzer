#
# Enterprise base Dockerfile
#

# Pull base image.
FROM centos:latest

# Install dependencies
RUN yum install -y git bzip2 which wget gcc-c++ make git-svn unzip epel-release readline-devel openssl-devel automake libtool bison \
    && yum install -y perl php java-1.8.0-openjdk java-1.8.0-openjdk-devel python-devel \
    && yum clean all

# Set JAVA_HOME max heap space for java
ENV JAVA_OPTS '-Xms512m -Xmx3072m'
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.71-2.b15.el7_2.x86_64

# Set default encoding
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV HEAPSIZE 3072m

# Install pip
RUN curl https://bootstrap.pypa.io/get-pip.py | python

# Install ruby 2.2.3
RUN cd /tmp && \
    wget https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.bz2 && \
    tar -xvjf /tmp/ruby-2.2.3.tar.bz2 && \
    cd /tmp/ruby-2.2.3 && \
    ./configure && \
    make && \
    make install

RUN gem install bundler

# Install Go 1.5
RUN cd /tmp && \
    wget https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.5.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/godoc /usr/local/bin/godoc && \
        mkdir /root/go
ENV GOPATH /root/go
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin

# Install Node.js
RUN curl --silent --location https://rpm.nodesource.com/setup | bash - \
    && yum install -y nodejs --enablerepo=epel


WORKDIR /root

# Define default command.
CMD ["/bin/bash"]
