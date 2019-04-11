FROM python:2.7-alpine AS builder
ARG ELASTALERT_VERSION=0.1.39
ARG ELASTALERT_HOME=/opt/elastalert

RUN apk add --update ca-certificates openssl-dev openssl libffi-dev gcc musl-dev && \
    wget https://github.com/Yelp/elastalert/archive/v${ELASTALERT_VERSION}.zip -O elastalert.zip && \
    unzip elastalert.zip && \
    mv elastalert-* "${ELASTALERT_HOME}"

WORKDIR "${ELASTALERT_HOME}"
RUN python setup.py install && \
    pip install -r requirements.txt

FROM python:2.7-alpine AS runner
RUN apk add --update --no-cache curl tzdata make libmagic
COPY --from=builder /usr/local/lib/python2.7/site-packages/ /usr/local/lib/python2.7/site-packages/
COPY --from=builder /opt/elastalert /opt/elastalert
COPY --from=builder /usr/local/bin/elastalert* /usr/local/bin/

WORKDIR /opt/elastalert-server
COPY . /opt/elastalert-server
ENTRYPOINT ["/usr/local/bin/elastalert"]
