FROM python:3.7.2

# creates a CLI environment:
# * python 3.7.2 environment
# * assumes /bmeg-etl mounted
# Uses service_account_email argument and config/service_account.json

# install mongo import

RUN apt-get install gnupg curl

RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
           -e 's|security.debian.org|archive.debian.org/|g' \
           -e '/stretch-updates/d' /etc/apt/sources.list

RUN curl -fsSL https://pgp.mongodb.com/server-4.4.asc | \
    gpg -o /usr/share/keyrings/mongodb-server-4.4.gpg \
   --dearmor

RUN echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-4.4.gpg ] http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list

RUN apt-get update
RUN apt-get install -y mongodb-org-tools


# install go lang, silence wget and tar
RUN wget -q  https://dl.google.com/go/go1.20.5.linux-amd64.tar.gz && \
  tar -xf go1.20.5.linux-amd64.tar.gz

# install grip
RUN mkdir -p /go/src/github.com/bmeg
WORKDIR /go/src/github.com/bmeg
ENV GOPATH=/go
ENV PATH="/go/bin:${PATH}"
RUN git clone https://github.com/bmeg/grip
ENV GOPROXY="https://proxy.golang.org"
RUN cd grip && \
  make

COPY docker-start.sh /docker-start.sh
COPY load_database.sh /etl/load_database.sh
WORKDIR /etl
ENTRYPOINT ["/docker-start.sh"]
