# This image is used for run ansible-playbook commands.
#
FROM python:3.7-buster

ARG ANSIBLE_RELEASE=2.9.9

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        openssl \
        unzip \
    && pip install ansible==${ANSIBLE_RELEASE} \
    && useradd -ms /bin/bash ansible \
    && mkdir -p /home/ansible/.ansible /home/ansible/.ssh \
    && chmod 700 /home/ansible/.ssh \
    && chown ansible:ansible -R /home/ansible/ \
    && apt-get clean \
    && rm -rf \
        ~/.cache/pip \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

USER ansible
WORKDIR /app/ansible

ENTRYPOINT ["ansible-playbook"]
