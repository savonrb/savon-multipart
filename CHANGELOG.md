## 2.1.2 (2022-01-20)

* Loosen dependency on `mail` gem. ([#23](https://github.com/savonrb/savon-multipart/pull/23))
* Add ability to flatten MTOM XOP parts back into the main XML document ([#17](https://github.com/savonrb/savon-multipart/pull/17))

## 2.1.1

* Improve detection of multipart content-type header.

## 2.1.0

* Drops support for ruby 1.8.7

## 2.0.2
* Removes hardcoded version lock on Mail gem

## 2.0.0
* Rewrite of savon-multipart to work with Savon 2.0+
  This includes all of the existing functionality in savon-multipart
  for savon1, but in a way that will be easier to maintain.

## 0.9.7

* Initial version. Adds multipart support (SOAP with Attachments) to Savon v0.9.7.
  Please test and provide feedback so we can merge this into Savon proper.


