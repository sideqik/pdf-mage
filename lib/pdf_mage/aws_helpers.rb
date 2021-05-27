module PdfMage
  module AwsHelpers

    def validate_aws_config!
        unless string_exists?(CONFIG.aws_account_key)
          raise ArgumentError, 'You must define aws_account_key in your config file'
        end

        unless string_exists?(CONFIG.aws_account_secret)
          raise ArgumentError, 'You must define aws_account_secret in your config file'
        end

        unless string_exists?(CONFIG.aws_account_region)
          raise ArgumentError, 'You must define aws_account_region in your config file'
        end

        unless string_exists?(CONFIG.aws_account_bucket)
          raise ArgumentError, 'You must define aws_account_bucket in your config file'
        end

        true
    end
  end
end
