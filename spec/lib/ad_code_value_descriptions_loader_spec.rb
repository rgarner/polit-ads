require 'rails_helper'
require 'polit_ads/ad_code_value_descriptions_loader'

RSpec.describe AdCodeValueDescriptionsLoader do
  subject(:loader) { AdCodeValueDescriptionsLoader.new(source_dir) }

  context 'the source dir has stuff in which we are interested' do
    # Has 1/md, 1/rd, 5/ocpmye
    let(:source_dir) { 'spec/fixtures/ad_code_values' }

    describe '#dir' do
      example { expect(loader.dir).to eql(source_dir) }
    end

    describe '#markdown_files' do
      subject(:files) { loader.markdown_files }

      it { is_expected.to be_an(Enumerator) }
      it { is_expected.to all(be_a(AdCodeValueDescriptionsLoader::MarkdownFile)) }

      describe 'the first of these' do
        subject(:file) { files.sort { |a, b| a.index <=> b.index }.min { |a, b| a.value <=> b.value } }

        it 'has index, value and file' do
          aggregate_failures do
            expect(file.campaign_slug).to eql('trump')
            expect(file.index).to eql(1)
            expect(file.value).to eql('md')
            expect(file.confidence).to eql('high')
            expect(file.content).to include('ad goal')
          end
        end
      end
    end

    describe '#create_or_update' do
      let(:trump)        { create :campaign, :trump }
      let(:donor_action) { create :ad_code, campaign: trump, index: 1 }
      let!(:optimise)    { create :ad_code, campaign: trump, index: 5 }

      let(:md)     { AdCodeValueDescription.where(ad_code: donor_action, value: 'md').first }
      let(:rd)     { AdCodeValueDescription.where(ad_code: donor_action, value: 'rd').first }
      let(:ocpmye) { AdCodeValueDescription.where(ad_code: optimise, value: 'ocpmye').first }

      before do
        create :ad_code_value_description, ad_code: donor_action, value: 'md', description: 'stuff'

        loader.create_or_update
      end

      it 'updated the existing 1/md and created the rest' do
        expect(AdCodeValueDescription.count).to eql(3)

        aggregate_failures do
          expect(md.description).to include('Why do we think that?')
          expect(md.value_name).to eql('Monthly donor')
          expect(md.confidence).to eql('high')
          expect(rd.description).to include('This is the description for rd')
          expect(rd.value_name).to include('Repeat donor')
          expect(rd.ad_code.index).to eql(1)
          expect(rd.published).to be_a(Date)
          expect(ocpmye.description).to include('This is to engage people, to get clicks')
          expect(ocpmye.value_name).to include('Optimise for clicks-per-mille engagement')
          expect(ocpmye.ad_code.index).to eql(5)
        end
      end
    end
  end
end
