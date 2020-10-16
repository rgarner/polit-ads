require 'rails_helper'

require 'polit_ads/ad_code_descriptions_loader'
require 'polit_ads/ad_code_value_descriptions_loader'

RSpec.describe 'Loading ad codes and values from markdown' do
  before do
    create :campaign, :trump
    create :campaign, :biden
  end

  let(:quiet_output) { double('STDOUT', puts: nil) }

  it 'all works without error' do
    AdCodeDescriptionsLoader.new('doc/ad_codes', quiet_output).create_or_update
    AdCodeValueDescriptionsLoader.new('doc/ad_code_values', quiet_output).create_or_update
  end
end
