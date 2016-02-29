#
# Enterprise Dockerfile
#

# Pull base image.
FROM blissai/base

# Install CSSlint, ESlint, nsp
RUN npm install -g jshint csslint eslint nsp coffeelint stylint sass-lint

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
RUN curl -fsSL https://s3.amazonaws.com/bliss-cli-dependencies/tailor-install.sh | sh

# Install gometalinter
RUN go get github.com/alecthomas/gometalinter
RUN gometalinter --install --update

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
