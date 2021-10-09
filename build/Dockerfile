# This image is used for download or build service from source repository.
#
FROM golang:1.16.7

ARG TZ="UTC"

WORKDIR /app

ADD scripts/aritfact.sh entrypoint.sh

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && chmod +x entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
CMD [""]
