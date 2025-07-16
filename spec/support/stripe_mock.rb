# frozen_string_literal: true

require 'stripe_mock'

RSpec.configure do |config|
  config.before(:each) do
    StripeMock.start
  end

  config.after(:each) do
    StripeMock.stop
  end
end
