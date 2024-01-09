FROM biigle/build-dist AS intermediate

FROM pytorch/pytorch:2.1.2-cuda11.8-cudnn8-runtime
LABEL maintainer "Martin Zurowietz <martin@cebitec.uni-bielefeld.de>"

RUN LC_ALL=C.UTF-8 apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository -y ppa:ondrej/php \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        php8.1-cli \
        php8.1-curl \
        php8.1-xml \
        php8.1-pgsql \
        php8.1-mbstring \
        php8.1-redis \
    && apt-get purge -y software-properties-common \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libgl1 libglib2.0-0 \
        build-essential \
        git \
        libvips \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt \
    # Use --no-dependencies so torch is not installed again.
    && pip3 install --no-dependencies --index-url https://download.pytorch.org/whl/cu118 xformers==0.0.23 \
    && apt-get purge -y \
        build-essential \
        git \
    && apt-get -y autoremove \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/* \
    && rm -r /tmp/*

RUN echo "memory_limit=1G" > "/etc/php/8.1/cli/conf.d/memory_limit.ini"

WORKDIR /var/www

COPY --from=intermediate /etc/localtime /etc/localtime
COPY --from=intermediate /etc/timezone /etc/timezone
COPY --from=intermediate /var/www /var/www
