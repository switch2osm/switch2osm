FROM ruby:3.1 as build

# Add Gem build requirements
RUN apt-get update && apt-get install -y \
  g++ \
  make \
  && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Add Gemfile and Gemfile.lock
ADD Gemfile* /app/

# Install Gems
RUN gem install bundler -v 2.4.5 \
    && bundle config build.nokogiri --use-system-libraries \
    && bundle config --global jobs $(nproc) \
    && bundle install

# Copy Site Files
COPY . .

# Run jekyll serve
CMD ["bundle","exec","jekyll","serve","--host=0.0.0.0","-wl"]
