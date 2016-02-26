#
# BlissCollector Dockerfile
#

# Pull base image.
FROM centos:latest

# Install dependencies
RUN yum install -y git bzip2 which wget gcc-c++ make perl php java-1.8.0-openjdk java-1.8.0-openjdk-devel git-svn unzip epel-release python-devel readline-devel libffi-devel openssl-devel automake libtool bison && \
    yum clean all

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

# Set max heap space for java
ENV JAVA_OPTS '-Xms512m -Xmx2048m'

# Install Node.js, CSSlint, ESlint, nsp
RUN curl --silent --location https://rpm.nodesource.com/setup | bash - \
    && yum install -y nodejs --enablerepo=epel \
    && npm install -g jshint csslint eslint nsp

# Clone phpcs & wpcs & pmd & ocstyle
RUN cd /root \
    && git clone https://github.com/founderbliss/ocstyle.git /root/ocstyle \
    && git clone https://github.com/iconnor/pmd.git /root/pmd \
    && git clone https://github.com/squizlabs/PHP_CodeSniffer.git /root/phpcs \
    && git clone https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git /root/wpcs \
    && /root/phpcs/scripts/phpcs --config-set installed_paths /root/wpcs

# Install Perl Critic
RUN yum install -y 'perl(Perl::Critic)'

# Install pip modules
RUN pip install importlib argparse lizard django prospector parcon ocstyle

# Install Tailor
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.71-2.b15.el7_2.x86_64
RUN curl -fsSL https://s3.amazonaws.com/bliss-cli-dependencies/tailor-install.sh | sh

# Install gometalinter
RUN go get github.com/alecthomas/gometalinter
RUN gometalinter --install --update

# Set default encoding
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV HEAPSIZE 3072m

ENV BLISS_CLI_VERSION 68

# Get collector tasks and gems
# RUN git clone -b cloud https://github.com/founderbliss/enterprise-analyzer.git /root/collector \
RUN git clone https://github.com/founderbliss/enterprise-analyzer.git /root/collector \
    && cd /root/collector \
    && bundle install --without test \
    && mkdir /root/bliss && mv /root/collector/.prospector.yml /root/bliss/.prospector.yml

WORKDIR /root/collector

# Define default command.
CMD ["/bin/bash"]
