ARG RUBY_BASE_IMAGE=ruby:latest
FROM $RUBY_BASE_IMAGE

ARG BUNDLE_GEMFILE
ENV BUNDLE_GEMFILE=$BUNDLE_GEMFILE

WORKDIR /usr/src/app

# No docs, they slow us down and we don't need them.
COPY docker/gemrc.yml /root/.gemrc

COPY . .

RUN set -eux; \
  CPUS=$(nproc | ruby -pe '[Integer($_) - 1, 1].max'); \
  MAKEFLAGS="--jobs=${CPUS}" \
  bundle install --verbose --retry 3 --no-cache --jobs=${CPUS}
