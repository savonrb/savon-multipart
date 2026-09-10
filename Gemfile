source 'https://rubygems.org'
gemspec

if RUBY_VERSION > "3.1"
  # net-smtp, net-pop and net-imap were removed from ruby 3.1 standard gems. See: https://github.com/rails/rails/pull/42366
  # Can drop when https://github.com/mikel/mail/pull/1439 is resolved
  gem "net-imap", require: false
  gem "net-pop", require: false
  gem "net-smtp", require: false
end

gem "rubocop", "~> 1.86", ">= 1.86.2"
gem "rubocop-rake", "~> 0.7.1"
gem "rubocop-rspec", "~> 3.9"

gem "bundler-audit", "~> 0.9.3", require: false
gem "ruby_audit", "~> 3.1", require: false if RUBY_VERSION >= "3.1.0"
