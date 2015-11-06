# Hiera::Backend::Trocla

This is a simple hiera backend to retreive passwords from trocla.

The idea of this backend is to enable you to use secrets from trocla
directly from your hiera data via interpolation tokens.

## Installation

Simply install the gem and hiera will find it automatically

    $ gem install hiera-backend-trocla

## Usage

The trocla hiera backend will resolve all the variables which start with "trocla_lookup::"
everything else will just be ignored.

The second part of the variable is used to describe the format, the last part is the variable
to lookup in trocla.

    torcla_lookup::plan::myvar

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


### Examples

You can use the Trocla Hiera backend via interpolation tokens like this:

    myapp::database::password: "%{hiera('trocla_lookup::plain::myapp_mysql_password')}"

    mysql::server::users:
      'someuser@localhost':
          ensure: 'present'
          password_hash: "%{hiera('trocla_lookup::mysql::myapp_mysql_password')}"

If the password is not already set, trocla will create one for you.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
