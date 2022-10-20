FROM ruby:3.0.3
RUN gem install bundler:2.2.19 -N
RUN mkdir /app
WORKDIR /app
COPY . /app

RUN bundle install --jobs 4 --retry 5 --quiet

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]

CMD [ "bin/console" ]
