# PdfMage ![Build Status](https://travis-ci.org/sideqik/pdf-mage.svg?branch=master) [![Codacy Badge](https://api.codacy.com/project/badge/Grade/49a43b30df054740910ac010042372bb)](https://www.codacy.com/app/Sideqik/pdf-mage?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sideqik/pdf-mage&amp;utm_campaign=Badge_Grade) [![Coverage Status](https://coveralls.io/repos/github/sideqik/pdf-mage/badge.svg?branch=master)](https://coveralls.io/github/sideqik/pdf-mage?branch=master)

PdfMage is a standalone microservice packaged as a Ruby gem that you makes it simple to render PDFs using Headless Chrome on a standalone server.

It includes support for:

- Uploading PDFs to AWS S3
- Webhooks
- API "secrets" for security

Please note, the documentation is still in-progress!

## Installation

Clone the repository to your computer and navigate to the directory:

```sh
git clone https://github.com/sideqik/pdf-mage.git
cd pdf-mage
```

Then install bundler if you haven't already done so:

```sh
gem install bundler
```

Finally, run the setup command:

```sh
bin/setup
```

## Running the Server

To run the server, you need to turn run both the API and the Sidekiq job server. If running in production, make sure to enable the environment flag for it, or else it'll default to the development environment.

```sh
PDFMAGE_ENV=production bin/pdf_mage
PDFMAGE_ENV=production bin/sidekiq
```

We recommend using a service such as `monit` to keep these processes alive in production, as system issues could cause them to crash and not be restarted.

## Configuration

Create a config.yml.local file and overwrite any of the following properties:

| name | type | description |
| ---- | ---- | ----------- |
| api_secret | String | TBD |
| aws_account_key | String | Key in your AWS S3 API credentials
| aws_account_bucket | String | Bucket to upload PDFs into
| aws_account_region | String | Region to upload PDFs into
| aws_account_secret | String | Secret in your AWS S3 API credentials
| aws_presigned_url_duration | Integer | How long the returned URL in the presigned-request should exist for, in seconds
| chrome_exe | String | Path to the Chrome executable
| delete_file_on_upload | Boolean | Whether or not to delete PDFs after they're uploaded
| log_level | String | What level of logs to write to the logfile
| pdf_directory | String | Where to locally store PDFs

Then, when starting the server, pass `CONFIG_FILE=config.yml.local`.

```sh
CONFIG_FILE=config.yml.local bin/pdf_mage
CONFIG_FILE=config.yml.local bin/sidekiq
```

### Using the "Secret" for Security

If you use the API secret config option, you can add security to your application. Adding a secret will:

1. Require you to pass a "secret" param with every request to PDF Mage's render resource, where the value is the secret set in the config.
2. Request the website url you want PDF Mage to render with a "secret" parameter, with the value you set in the config.
3. Sign the webhook sent to your server with a SHA256 hexdigest as a "X-Pdf-Signature" header. See info about checking the signature below.

**To check the X-Pdf-Signature header:**

1. Create a SHA256 HMAC hexdigest using the config secret as the key and the response body as the data.
2. Compare the hexdigest to the signature provided.

**Example in Ruby:**

```ruby
# Generate the signature that should have been returned
valid_signature = OpenSSL::HMAC.hexdigest('sha256', CONFIG.api_secret, response.body)

# Compare the signatures
response.headers['X-Pdf-Signature'] == valid_signature
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sidekiq/pdf_mage. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PdfMage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sidekiq/pdf_mage/blob/master/CODE_OF_CONDUCT.md).
