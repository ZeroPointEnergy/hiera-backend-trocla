require 'spec_helper'
require 'hiera'

describe Hiera::Backend::Trocla do

  before :each do
    @hiera = Hiera.new(:config => "spec/config/hiera.yaml")
    @trocla = Trocla.new(@hiera.config[:trocla][:config])
  end

  describe 'trocla_lookup' do
    it 'will create a new password and return the same password on the second lookup' do
      password1 = @hiera.lookup('trocla_lookup::plain::my_secret_password', nil, nil)
      password2 = @hiera.lookup('trocla_lookup::plain::my_secret_password', nil, nil)
      expect(password1).to eq(password2)
    end

    it 'will create different passwords for each key' do
      password1 = @hiera.lookup('trocla_lookup::plain::my_secret_password', nil, nil)
      password2 = @hiera.lookup('trocla_lookup::plain::my_secret_password2', nil, nil)
      expect(password1).not_to eq(password2)
    end

    it 'will return the correct password if retrieved via interpolation' do
      password = @hiera.lookup('trocla_lookup::plain::my_secret_password', nil, nil)
      expect(@hiera.lookup('var_with_password', nil, nil)).to eq(password)
    end

    it 'will not influence normal lookups' do
      expect(@hiera.lookup('normal_var', nil, nil)).to eq('test')
    end

    it 'will return nil if the format is not valid' do
      expect{@hiera.lookup('trocla_lookup::unexisting::my_secret_password', nil, nil)}.to raise_error StandardError
      expect{@hiera.lookup('var_with_invalid_format', nil, nil)}.to raise_error StandardError
    end

    it 'will be able to influence the trocla key' do
      x509 = @hiera.lookup('var_with_x509',nil, nil)
      expect(x509).to match(/BEGIN RSA PRIVATE KEY/)
      expect(x509).to match(/BEGIN CERTIFICATE/)
      x509_key = @hiera.lookup('var_with_x509_key',nil, nil)
      expect(x509_key).to match(/BEGIN RSA PRIVATE KEY/)
      expect(x509_key).not_to match(/BEGIN CERTIFICATE/)

      # given that hiera trocla options point to the same
      # trocla key, it must be the same key
      expect(OpenSSL::PKey::RSA.new(x509).to_pem).to eql(
        OpenSSL::PKey::RSA.new(x509_key).to_pem)
    end
  end

  describe 'trocla_hierarchy' do
    it 'will return a different password for two different nodes' do
      scope1 = {'::clientcert' => 'node01.example.com'}
      password1 = @hiera.lookup('trocla_hierarchy::plain::node_specific', nil, scope1)
      scope2 = {'::clientcert' => 'node02.example.com'}
      password2 = @hiera.lookup('trocla_hierarchy::plain::node_specific', nil, scope2)
      expect(password1).not_to eq(password2)
    end

    it 'will return a different password for two different nodes' do
      scope1 = {'::clientcert' => 'node01.example.com'}
      password1 = @hiera.lookup('trocla_hierarchy::plain::not_node_specific', nil, scope1)
      scope2 = {'::clientcert' => 'node02.example.com'}
      password2 = @hiera.lookup('trocla_hierarchy::plain::not_node_specific', nil, scope2)
      expect(password1).to eq(password2)
    end

    it 'will return the same password for both nodes in the same role' do
      scope1 = {'::clientcert' => 'node01.example.com', '::role' => 'same'}
      password1 = @hiera.lookup('trocla_hierarchy::plain::same_role', nil, scope1)
      scope2 = {'::clientcert' => 'node02.example.com', '::role' => 'same'}
      password2 = @hiera.lookup('trocla_hierarchy::plain::same_role', nil, scope2)
      expect(password1).to eq(password2)
    end

    it 'will return different passwords for nodes in different roles' do
      scope1 = {'::clientcert' => 'node01.example.com', '::role' => 'role1'}
      password1 = @hiera.lookup('trocla_hierarchy::plain::different_role', nil, scope1)
      scope2 = {'::clientcert' => 'node02.example.com', '::role' => 'role2'}
      password2 = @hiera.lookup('trocla_hierarchy::plain::different_role', nil, scope2)
      expect(password1).not_to eq(password2)
    end
    it 'will be able to influence the trocla key' do
      scope1 = {'::clientcert' => 'node01.example.com', '::role' => 'role1'}
      scope2 = {'::clientcert' => 'node02.example.com', '::role' => 'role1'}
      x509 = @hiera.lookup('hiera_var_with_x509',nil, scope1)
      expect(x509).to match(/BEGIN RSA PRIVATE KEY/)
      expect(x509).to match(/BEGIN CERTIFICATE/)
      x509_key = @hiera.lookup('hiera_var_with_x509_key',nil, scope2)
      expect(x509_key).to match(/BEGIN RSA PRIVATE KEY/)
      expect(x509_key).not_to match(/BEGIN CERTIFICATE/)

      # given that hiera trocla options point to the same
      # trocla key, it must be the same key
      expect(OpenSSL::PKey::RSA.new(x509).to_pem).to eql(
        OpenSSL::PKey::RSA.new(x509_key).to_pem)
    end
  end

  describe 'options hash merging' do
    it 'will crate a password with the default length' do
      password = @hiera.lookup('trocla_lookup::plain::default_length', nil, nil)
      expect(password.length).to eq(16)
    end

    it 'will create a password with the length for mysql format' do
      mysql_password = @hiera.lookup('trocla_lookup::mysql::mysql_length', nil, nil)
      password = @hiera.lookup('trocla_lookup::plain::mysql_length', nil, nil)
      expect(password.length).to eq(32)
    end

    it 'will create a password with the length defined for the key' do
      password = @hiera.lookup('trocla_lookup::plain::special_length', nil, nil)
      expect(password.length).to eq(64)
    end
    it 'will create a password with the length defined for the key, derived from another option' do
      password2 = @hiera.lookup('trocla_lookup::plain::special_length2', nil, nil)
      expect(password2.length).to eq(128)
    end
  end

end
