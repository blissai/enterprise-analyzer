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
RUN pip3 install django prospector bandit
RUN pip install argparse parcon ocstyle

# Install lizard
RUN git clone https://github.com/terryyin/lizard.git ~/lizard && \
    cd ~/lizard && \
    python3.4 setup.py install

# Install Tailor
RUN curl -fsSL https://s3.amazonaws.com/bliss-cli-dependencies/tailor-install.sh | sh

# Install gometalinter
RUN go get github.com/alecthomas/gometalinter
RUN gometalinter --install --update

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

# Install ScalaStyle
RUN mkdir ~/scalastyle \
    && wget -O ~/scalastyle/scalastyle.jar https://oss.sonatype.org/content/repositories/releases/org/scalastyle/scalastyle_2.10/0.8.0/scalastyle_2.10-0.8.0-batch.jar \
    && echo '#!/bin/bash' > ~/scalastyle/scalastyle \
    && echo 'java -jar ~/scalastyle/scalastyle.jar "$@"' >> ~/scalastyle/scalastyle \
    && chmod +x ~/scalastyle/scalastyle \
    && ln -s ~/scalastyle/scalastyle /usr/local/bin/scalastyle

# Install CCM and tslint
RUN wget -O /tmp/ccm.zip https://github.com/jonasblunck/ccm/releases/download/v1.1.9/ccm.1.1.9.zip \
    && unzip /tmp/ccm.zip -d /root/ccm

# Install CSSlint, ESlint, nsp
RUN npm install -g jshint@2.9.2 csslint@0.10.0 eslint@2.8.0 nsp@2.3.1 coffeelint@1.15.7 stylint@1.3.8 sass-lint jscpd@0.6.1 eslint-config-airbnb@7.0.0 eslint-config-hapi@9.1.0 typescript tslint@3.8.1
# RUN npm install -g jshint csslint eslint nsp coffeelint stylint sass-lint jscpd eslint-config-airbnb eslint-config-hapi tslint

# Install gems before adding of project to use caching properly
COPY Gemfile* /tmp/
RUN cd /tmp && bundle install --without test

ENV BLISS_CLI_VERSION=90 CLOC_VERSION=1 LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8

# Get collector tasks and gems
ADD . /root/collector
RUN mkdir /root/bliss && mv /root/collector/.prospector.yml /root/bliss/.prospector.yml \
    && mv /root/collector/phpmd-ruleset.xml /root/phpmd/phpmd-ruleset.xml

WORKDIR /root/collector

# Define default command.
CMD ["/bin/bash"]
