#
# Enterprise base Dockerfile
#

# Pull base image.
FROM centos:latest

# Install Mono and Node repos
RUN rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" && \
    yum-config-manager --add-repo http://download.mono-project.com/repo/centos/ && \
    curl --silent --location https://rpm.nodesource.com/setup_5.x | bash - && \

# Install dependencies
    yum install -y git bzip2 which wget gcc-c++ make git-svn unzip epel-release readline-devel openssl-devel automake libtool bison && \
    yum install -y perl php java-1.8.0-openjdk java-1.8.0-openjdk-devel python-devel php-xml mono-complete nuget nodejs python34  && \
    yum clean all  && \

# Increase PHP Memory Limit
    sed -i 's/memory_limit = .*/memory_limit = 2048m/' /etc/php.ini && \

# Install pip
    curl https://bootstrap.pypa.io/get-pip.py | python3.4 && \
    curl https://bootstrap.pypa.io/get-pip.py | python && \


# Install fpart
    git clone https://github.com/martymac/fpart.git /tmp/fpart \
    && cd /tmp/fpart \
    && autoreconf -i \
    && ./configure \
    && make \
    && make install

# Install ruby 2.3.1
RUN cd /tmp && \
    wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.bz2 && \
    tar -xvjf /tmp/ruby-2.3.1.tar.bz2 && \
    cd /tmp/ruby-2.3.1 && \
    ./configure && \
    make && \
    make install && \
    gem install bundler && \

# Install Go 1.5
    cd /tmp && \
    wget https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf /tmp/go1.5.linux-amd64.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/godoc /usr/local/bin/godoc && \
    mkdir /root/go && \

# Install NAnt
    cd /tmp && \
    mkdir /tmp/nant && \
    wget http://nant.sourceforge.net/nightly/latest/nant-src.tar.gz && \
    tar -xvf /tmp/nant-src.tar.gz -C /tmp/nant --strip-components 1 && \
    sed -i 's/MCS=gmcs/MCS=mcs/' /tmp/nant/Makefile && \
    cd /tmp/nant && \
    make && \
    make install && \
    ln -s /usr/bin/mono /usr/local/bin/mono && \

# Install Erlang and Elixir
    mkdir /tmp/elixir && \
    wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm && \
    rpm -Uvh erlang-solutions-1.0-1.noarch.rpm && \
    yum install -y erlang && \
    wget -O /tmp/elixir/pre.zip https://github.com/elixir-lang/elixir/releases/download/v1.2.4/Precompiled.zip && \
    mkdir -p /usr/local/elixir && cd /usr/local/elixir && unzip /tmp/elixir/pre.zip && \
    ln -s /usr/local/elixir/bin/elixir /usr/local/bin/elixir && \
    ln -s /usr/local/elixir/bin/elixirc /usr/local/bin/elixirc && \
    ln -s /usr/local/elixir/bin/iex /usr/local/bin/iex && \
    ln -s /usr/local/elixir/bin/mix /usr/local/bin/mix && \
    mix local.hex <<< 'Y' && \
    mix local.rebar <<< 'Y' && \

  # Install Scala
    wget -O /tmp/scala.tgz http://downloads.lightbend.com/scala/2.11.8/scala-2.11.8.tgz && \
    cd /tmp && \
    tar xvf /tmp/scala.tgz && \
    mv scala-2.11.8 /usr/lib && \
    ln -s /usr/lib/scala-2.11.8 /usr/lib/scala

# Set ENV VARS
ENV GOPATH=/root/go PATH=$PATH:/usr/local/go/bin:/root/go/bin:/usr/lib/scala/bin JAVA_OPTS='-Xms512m -Xmx3072m' JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.91-0.b14.el7_2.x86_64 HEAPSIZE=3072m

WORKDIR /root

# Define default command.
CMD ["/bin/bash"]
