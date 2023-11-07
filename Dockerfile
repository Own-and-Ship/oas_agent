ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION

# No docs, they slow us down and we don't need them.
RUN { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /etc/gemrc

WORKDIR /usr/src/app
COPY . .

# Install bundler version compatible with older Ruby versions and install gems
RUN if ruby -e 'exit RUBY_VERSION < "2.6"'; then \
        gem install bundler -v '<= 2.3.26'; \
    else \
        gem install bundler -v "$(tail -n1 Gemfile.lock | tr -d ' ')"; \
    fi
RUN bundle

CMD ["bundle", "exec", "rake"]
