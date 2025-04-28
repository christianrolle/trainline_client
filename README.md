# README

Please setup the bot according to the following recipe:

- [ ] Cop ENV file based on the template
  ```bash
  cp .env.development.erb .env
  ```
- [ ] Build the containers with
  ```bash
  docker compose up --build
  ```
- [ ] Install the gems permanently
  ```bash
  docker compose run api_client bundle install
  ```
- [ ] Run the specs
  ```bash
  docker compose run api_client bundle exec rspec spec/services/com_the_trainline_spec.rb
  ```
- [ ] Open the CLI
  ```bash
  docker compose run api_client bundle exec rails c
  ```
- [ ] Play around
  ```ruby
  ComTheTrainline.find 'London', 'Paris', Time.parse('2025-04-28T14:00:00')
  ```
