FROM ruby:3.3-alpine AS builder

RUN apk --no-cache add \
            build-base \
            cmake \
            git \
            icu-dev \
            openssl-dev \
            yaml-dev

COPY Gemfile* /tmp/
COPY gollum.gemspec* /tmp/
WORKDIR /tmp
RUN bundle install

RUN gem install \
    asciidoctor \
    creole \
    wikicloth \
    org-ruby \
    RedCloth \
    bibtex-ruby \
    && echo "gem-extra complete"

WORKDIR /app
COPY . /app
RUN bundle exec rake install

FROM ruby:3.3-alpine

ARG UID=1000
ARG GID=1000

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

WORKDIR /wiki
RUN apk --no-cache add \
            bash \
            git \
            gcompat \
            openssh \
    && delgroup www-data \
    && addgroup -g $GID www-data \
    && adduser -S -u $UID -G www-data www-data \
    && git config --file /home/www-data/.gitconfig --add safe.directory /wiki \
    && chown www-data:www-data /home/www-data/.gitconfig

COPY docker-run.sh /docker-run.sh
RUN chmod +x /docker-run.sh
USER www-data
VOLUME /wiki

ENTRYPOINT ["/docker-run.sh"]
