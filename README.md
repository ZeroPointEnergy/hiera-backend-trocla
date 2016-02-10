# Hiera Backend for Trocla

[![Build Status](https://travis-ci.org/ZeroPointEnergy/hiera-backend-trocla.svg)](https://travis-ci.org/ZeroPointEnergy/hiera-backend-trocla)
[![Code Climate](https://codeclimate.com/github/ZeroPointEnergy/hiera-backend-trocla/badges/gpa.svg)](https://codeclimate.com/github/ZeroPointEnergy/hiera-backend-trocla)
[![Test Coverage](https://codeclimate.com/github/ZeroPointEnergy/hiera-backend-trocla/badges/coverage.svg)](https://codeclimate.com/github/ZeroPointEnergy/hiera-backend-trocla/coverage)

This is a simple hiera backend to retrieve passwords from trocla.

The idea of this backend is to enable you to use secrets from trocla
directly from your hiera data via interpolation tokens.

A lot of the ideas for the improvement of this backend came from the 
[trocla hiera plugin](https://github.com/duritong/puppet-trocla/pull/15)
from @michaelweiser.

## Installation

Simply install the gem and hiera will find it automatically

    $ gem install hiera-backend-trocla

## Usage

Add the backend to your hiera.yaml to use it.

    :backends:
        - 'trocla'
        - 'yaml'
    :hierarchy:
        - 'defaults'
    :yaml:
        :datadir: '/path/to/your/hieradata'
    :trocla:
        :config: '/path/to/your/troclarc.yaml'

There are two different methods to lookup a password in trocla. trocla_lookup and trocla_hierarchy

### trocla_lookup

trocla_lookup will simply lookup the password for a specified key and completely ignore
the hierarchy defined in the hiera configuration. If the password does not exist it will
create one.

The trocla hiera backend will resolve all the variables which start with "trocla_lookup::"

The second part of the variable is used to describe the format, the last part is the variable
to lookup in trocla.

    trocla_lookup::format::myvar

You can use the backend via interpolation tokens like this:

    myapp::database::password: "%{hiera('trocla_lookup::plain::myapp_mysql_password')}"

    mysql::server::users:
      'someuser@localhost':
          ensure: 'present'
          password_hash: "%{hiera('trocla_lookup::mysql::myapp_mysql_password')}"

### trocla_hierarchy

trocla_hierarchy will lookup the key in the hierarchy defined in your hiera configuration.
It will simply prefix all the variables with 'hiera/source/key' where source is one of
the interpolated strings defined in the hierarchy section.

It will try to find a password on every level in your hierarchy first. After that it will
create a password on the first hierarchy level by default. You can overwrite the level it
should create the password with the key 'order_override' in the trocla_options hash.

This is useful if you require different key for different nodes or on any other hierarchy level
you desire.

If you have a hierarchy defined like this:

    :hierarchy:
      - "nodes/%{::clientcert}"
      - "roles/%{::role}"
      - defaults

And you want to create a different password on the roles level, so that nodes within the
same role will get the same password you can set the 'order_override' like this:

    trocla_options::my_special_key:
      order_override: "roles/%{::role}"

The format to lookup a password this way is the same as with 'trocla_lookup':

    trocla_hierarchy::format::myvar

Here is how you would use that in hiera:

    mysql::server::root_password: "%{hiera('trocla_hierarchy::plain::mysql_root')}"

### options hash

Trocla takes a hash of options which provides information for the password creation. This
options can be set directly in hiera globally or for every key. You can also specify options
specifically for a password format. However, keep in mind that trocla will respect most of
the options only on the initial/first lookup, when the password is created. As most of the
options only apply for creating a password.

    trocla_options:
      length: 16
      some_other_global_setting: bla
      mysql:
        length: 32

    trocla_options::some_key:
      plain:
        length: 64
      order_override: "roles/%{::role}"

Some formats may require options to be set for creating passwords, like the
postgresql format. Check the trocla documentation for available options.

Through the options mechanism it is also possible to change the lookup key used for trocla.
This is especially interesting, if you want to pass 2 different options for the same key,
e.g. the render option. An example for that is to have trocla use the same key for 2 different
lookups, so that with the x509 format, once a certificate and once a key is returned.


    var_with_x509_cert: "%{hiera('trocla_lookup::x509::my_cert')}"
    trocla_options::my_cert:
      x509:
        CN: 'my-cert'
        render:
          certonly: true
    var_with_x509_key: "%{hiera('trocla_lookup::x509::my_cert_only_key')}"
    trocla_options::my_cert_only_key:
      x509:
        CN: 'my-cert'
        trocla_key: my_cert
        render:
          keyonly: true

This will lookup one trocla key: my_cert, but with different rendering options, so that
once we only get the certificat, while on the second lookup we get the private key.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
