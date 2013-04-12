Savon Multipart [![Build Status](https://secure.travis-ci.org/savonrb/savon-multipart.png)](http://travis-ci.org/savonrb/savon-multipart)
===============

Adds multipart support (SOAP with Attachments) to [Savon](https://github.com/savonrb/savon).  
Please test and provide feedback so we can support as many multipart-soap messages as possible.


Savon2
------

Recently Savon launched a rewrite that broke compatibility with savon-multipart. If you're using savon
version 1, this should just work, but if you'd like to use Savon2, you will probably want to specify
something like this in your Gemfile


```
gem 'savon-multipart',       :git => 'https://github.com/tjarratt/savon-multipart.git', :branch => 'savon2'
```


Installation
------------

Savon Multipart is available through [Rubygems](http://rubygems.org/gems/savon-multipart) and can be installed via:

```
$ gem install savon-multipart
```
