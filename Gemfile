source 'https://rubygems.org'
gemspec

if RUBY_VERSION > "3.1"
  # net-smtp, net-pop and net-imap were removed from ruby 3.1 standard gems. See: https://github.com/rails/rails/pull/42366
  # Can drop when https://github.com/mikel/mail/pull/1439 is resolved
  gem "net-imap", require: false
  gem "net-pop", require: false
  gem "net-smtp", require: false
end
gem "rubocop", "~> 0.49.1"
