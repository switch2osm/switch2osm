FROM ruby:2.7-alpine as build

# Add Gem build requirements
RUN apk add --no-cache g++ make libxml2-dev libxslt-dev

# Create app directory
WORKDIR /app

# Add Gemfile and Gemfile.lock
ADD Gemfile* /app/

# Install Gems
RUN gem update --system \
    && gem install bundler -v $(grep -F -A 1 'BUNDLED WITH' Gemfile.lock | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+') \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle config --global jobs $(nproc) \
    && bundle install

# Copy Site Files
COPY . .

# Run jekyll serve
CMD ["bundle","exec","jekyll","serve","--host=0.0.0.0","-wl"]
