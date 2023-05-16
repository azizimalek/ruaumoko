# -------------------
# The build container
# -------------------
FROM debian:buster-slim AS build

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-cffi \
    python3-cffi \
    python3-docopt \
    libffi-dev \
    python3-wheel \
    unzip && \
  rm -rf /var/lib/apt/lists/*

COPY . /root/ruaumoko
COPY /srv/ruaumoko_dataset /srv/ruaumoko_dataset

RUN cd /root/ruaumoko && \
  pip3 install --user --no-warn-script-location --ignore-installed -r requirements.txt && \
  python3 setup.py build_ext --inplace

# -------------------------
# The application container
# -------------------------
FROM debian:buster-slim

EXPOSE 8023/tcp

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    imagemagick \
    python3 \
    tini && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /root/.local /root/.local
COPY --from=build /root/ruaumoko /root/ruaumoko

RUN rm /etc/ImageMagick-6/policy.xml && \
  mkdir -p /run/ruaumoko

WORKDIR /root

ENV PATH=/root/.local/bin:$PATH

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD /root/.local/bin/gunicorn -b 0.0.0.0:8023 --worker-class gevent -w 12 ruaumoko.api:app
