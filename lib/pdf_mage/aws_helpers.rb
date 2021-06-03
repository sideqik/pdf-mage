module PdfMage
  module AwsHelpers

    def self.validate_aws_config!
      if !CONFIG.aws_account_key || CONFIG.aws_account_key.empty?
        raise ArgumentError, 'You must define aws_account_key in your config file'
      end

      if !CONFIG.aws_account_secret || CONFIG.aws_account_secret.empty?
        raise ArgumentError, 'You must define aws_account_secret in your config file'
      end

      if !CONFIG.aws_account_region || CONFIG.aws_account_region.empty?
        raise ArgumentError, 'You must define aws_account_region in your config file'
      end

      if !CONFIG.aws_account_bucket || CONFIG.aws_account_bucket.empty?
        raise ArgumentError, 'You must define aws_account_bucket in your config file'
      end

      true
    end
  end
end
