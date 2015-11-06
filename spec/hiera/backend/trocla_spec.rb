require 'spec_helper'
require 'hiera'

describe Hiera::Backend::Trocla do

  before :each do
    @hiera = Hiera.new(:config => "spec/config/hiera.yaml")
  end

  it 'will return the correct password if retrieved directly' do
    expect(@hiera.lookup('trocla_lookup::plain::my_secret_password', nil, nil)).to eq('mysupersecretpassword')
  end

  it 'will return the correct password if retrieved via interpolation' do
    expect(@hiera.lookup('var_with_password', nil, nil)).to eq('mysupersecretpassword')
  end

  it 'will not influence normal lookups' do
    expect(@hiera.lookup('normal_var', nil, nil)).to eq('test')
  end

  it 'will return nil if the format is not valid' do
    expect{@hiera.lookup('trocla_lookup::unexisting::my_secret_password', nil, nil)}.to raise_error StandardError
    expect{@hiera.lookup('var_with_invalid_format', nil, nil)}.to raise_error StandardError
  end

end
