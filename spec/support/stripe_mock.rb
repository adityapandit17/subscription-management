# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    StripeMock.start
  end

  config.after(:each) do
    StripeMock.stop
  end
end
