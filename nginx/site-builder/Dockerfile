FROM ubuntu:18.04

# install node
RUN apt-get update
RUN apt-get install -y curl gnupg git build-essential wget
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

RUN wget https://github.com/gohugoio/hugo/releases/download/v0.54.0/hugo_0.54.0_Linux-64bit.deb
RUN dpkg -i hugo_0.54.0_Linux-64bit.deb
RUN rm hugo_0.54.0_Linux-64bit.deb

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn


RUN mkdir /bmeg
#WORKDIR /bmeg
#RUN git clone https://github.com/bmeg/bmeg-site.git
VOLUME ["/bmeg/bmeg-site"]
WORKDIR /bmeg/bmeg-site
