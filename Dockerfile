ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION

# No docs, they slow us down and we don't need them.
RUN { \
      echo 'install: --no-document'; \
      echo 'update: --no-document'; \
    } >> /etc/gemrc

WORKDIR /usr/src/app
COPY . .

RUN rm -r Gemfile.lock .ruby-lsp .git .github .DS_Store
# If we're removing the Gemfile.lock we may as well remove rubocop, it's
# a dev dep and won't affect tests or production
RUN sed -i '/spec\.add_development_dependency "rubocop"/d' oas_agent.gemspec

# Install bundler version compatible with older Ruby versions and install gems
RUN if ruby -e 'exit RUBY_VERSION < "2.3"' ; then \
        gem install bundler -v1.17.3; \
    elif ruby -e 'exit RUBY_VERSION < "2.4"' ; then \
        gem install bundler -v '<= 2.3.26'; \
    elif ruby -e 'exit RUBY_VERSION < "2.6"' ; then \
        gem install bundler -v '<= 2.3.26'; \
    else \
        gem install bundler -v "$(tail -n1 Gemfile.lock | tr -d ' ')"; \
    fi

# I can't get nokogiri to build on the older versions with the build-in libraries.
RUN if ruby -e 'exit RUBY_VERSION < "2.5"'; then \
        bundle config build.nokogiri "--use-system-libraries --with-xml2-include=/usr/local/opt/libxml2/include/libxml2"; \
    fi

RUN bundle

CMD ["bundle", "exec", "rake"]
