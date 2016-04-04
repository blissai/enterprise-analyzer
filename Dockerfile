#
# Enterprise Dockerfile
#

# Pull base image.
FROM blissai/base:latest

# Clone phpcs & wpcs & pmd & ocstyle
RUN cd /root \
    && git clone https://github.com/founderbliss/ocstyle.git /root/ocstyle \
    && git clone https://github.com/iconnor/pmd.git /root/pmd \
    && git clone https://github.com/squizlabs/PHP_CodeSniffer.git /root/phpcs \
    && git clone https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git /root/wpcs \
    && /root/phpcs/scripts/phpcs --config-set installed_paths /root/wpcs

# Install Perl Critic
RUN yum install -y 'perl(Perl::Critic)'

# Install PHPMD
RUN mkdir ~/phpmd && wget -O ~/phpmd/phpmd.phar -c http://static.phpmd.org/php/latest/phpmd.phar

# Install pip modules
RUN pip install importlib argparse django prospector parcon ocstyle

# Install lizard
RUN git clone https://github.com/terryyin/lizard.git ~/lizard && \
    cd ~/lizard && \
    python setup.py install

# Install Tailor
RUN curl -fsSL https://s3.amazonaws.com/bliss-cli-dependencies/tailor-install.sh | sh

# Install gometalinter
RUN go get github.com/alecthomas/gometalinter
RUN gometalinter --install --update

# Install CSSlint, ESlint, nsp
RUN npm install -g jshint csslint eslint nsp coffeelint stylint sass-lint jscpd eslint-plugin-react eslint-config-airbnb eslint-config-hapi

# Install SonarLint for .NET
RUN git clone --recursive https://github.com/mikesive/sonaranalyzer-csharp-mono.git ~/sonarlint
RUN cd ~/sonarlint && \
    nant && \
    cd ~/sonarlint/bin && \
    mono SonarLint.DocGenerator.exe

RUN git clone https://github.com/rrrene/bunt ~/bunt && \
    cd ~/bunt && \
    mix archive.build && \
    mix archive.install <<< 'Y' && \
    git clone https://github.com/rrrene/credo.git ~/credo && \
    cd ~/credo && \
    mix deps.get <<< 'Y' && \
    mix archive.build && \
    mix archive.install <<< 'Y'

# Install fpart
RUN git clone https://github.com/martymac/fpart.git /tmp/fpart \
    && cd /tmp/fpart \
    && autoreconf -i \
    && ./configure \
    && make \
    && make install

# Install gems before adding of project to use caching properly
COPY Gemfile* /tmp/
RUN cd /tmp && bundle install --without test

ENV BLISS_CLI_VERSION 90

# Get collector tasks and gems
ADD . /root/collector
RUN cd /root/collector \
    && mkdir /root/bliss && mv /root/collector/.prospector.yml /root/bliss/.prospector.yml \
    && mv /root/collector/phpmd-ruleset.xml /root/phpmd/phpmd-ruleset.xml

WORKDIR /root/collector

# Define default command.
CMD ["/bin/bash"]
