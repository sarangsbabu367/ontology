FROM ruby:2  

RUN mkdir /ontology_service
WORKDIR /ontology_service

COPY Gemfile ./
COPY Gemfile.lock ./
COPY ontology_lookup_service.rb ./

RUN gem install bundler -v '=1.17.2'
RUN bundle install

ENV ONTOLOGY_ID=

CMD ["sh", "-c", "ruby ontology_lookup_service.rb $ONTOLOGY_ID"]