# First stage
FROM alpine:3.11 AS builder

ENV MMD_REPO=https://github.com/metno/mmd
ENV MMD_VERSION=${MMD_VERSION:-master}
#ENV XSLTPATH=${XSLTPATH:-/usr/local/share/xslt}
ENV MMD_TOOLS_REPO=https://github.com/metno/py-mmd-tools
ENV MMD_TOOLS_VERSION=${MMD_TOOLS_VERSION:-master}

RUN apk add --no-cache \
  git

WORKDIR /

RUN git clone ${MMD_REPO}; \
  cd mmd; \
  git checkout ${MMD_VERSION}; \
  chmod +x /mmd/bin/convert_to_mmd

RUN git clone ${MMD_TOOLS_REPO}; \
  cd py-mmd-tools; \
  git checkout ${MMD_TOOLS_VERSION}

# Second stage
FROM alpine:3.11
LABEL maintainer="aheimsbakk@met.no"

RUN apk add \
  libxml2 \
  libxslt \
  python3
RUN apk add --no-cache --virtual .build-deps \
  build-base \
  libxml2-dev \
  libxslt-dev \
  py3-pip \
  python3-dev
RUN pip3 install --upgrade pip && \
      pip3 install --no-cache \
        lxml==4.5.0 \
        xmltodict==0.12.0 \
        parmap==1.5.2
RUN apk del .build-deps

RUN ln -sf /usr/bin/python3 /usr/bin/python; \
      mkdir -p /usr/local/share/xslt

COPY --from=builder /py-mmd-tools/script/xmlconverter.py /usr/local/bin
COPY --from=builder /py-mmd-tools/py_mmd_tools/ /usr/lib/python3.8/site-packages/py_mmd_tools/
COPY --from=builder /mmd/xslt/* /usr/local/share/xslt/
