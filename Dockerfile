FROM jakubborys/ditc-base

ADD wheelhouse /var/nameko/wheelhouse

COPY config.yml /var/nameko/config.yml

WORKDIR /var/nameko/

RUN . /appenv/bin/activate; \
    pip install --no-index -f wheelhouse products

RUN rm -rf /var/nameko/wheelhouse

EXPOSE 8000

CMD . /appenv/bin/activate; \
    nameko run --config config.yml products.service --backdoor 3000
