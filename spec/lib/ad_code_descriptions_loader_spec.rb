require 'rails_helper'
require 'polit_ads/ad_code_descriptions_loader'

RSpec.describe AdCodeDescriptionsLoader do
  subject(:loader) { AdCodeDescriptionsLoader.new(source_dir) }

  context 'the source dir has stuff in which we are interested' do
    let(:source_dir) { 'spec/fixtures/ad_codes' }

    describe '#dir' do
      example { expect(loader.dir).to eql(source_dir) }
    end

    describe '#markdown_files' do
      subject(:files) { loader.markdown_files }

      it { is_expected.to be_an(Enumerator) }
      it { is_expected.to all(be_a(AdCodeDescriptionsLoader::MarkdownFile)) }

      describe 'the first of these' do
        subject(:file) { files.sort { |a, b| a.index <=> b.index }.min { |a, b| a.index <=> b.index } }

        it 'has all its values' do
          aggregate_failures do
            expect(file.campaign_slug).to eql('trump')
            expect(file.slug).to eql('donor-action')
            expect(file.confidence).to eql('high')
            expect(file.index).to eql(1)
            expect(file.content).to include('ad goal')
          end
        end

        it 'removes the front matter' do
          expect(file.content_without_front_matter).not_to include('---')
        end
      end
    end

    describe '#create_or_update' do
      let!(:trump)        { create :campaign, :trump }
      let!(:donor_action) { create :ad_code, campaign: trump, index: 1 }
      let(:optimise)      { AdCode.find_by!(index: 5) }

      before do
        loader.create_or_update
        donor_action.reload
      end

      it 'updates the pre-existing donor action ad code' do
        aggregate_failures do
          expect(donor_action.name).to eql('Donor action')
          expect(donor_action.short_desc).to eql('The classification of the ad viewer in terms of their donor status')
          expect(donor_action.slug).to eql('donor-action')
          expect(donor_action.description).to include('some donor action markdown')
          expect(donor_action.quality).to eql(99)
          expect(donor_action.campaign).to eql(trump)
        end
      end

      it 'creates the optimise ad code' do
        aggregate_failures do
          expect(optimise.quality).to eql(98)
          expect(optimise.name).to eql('Some optimise ad code')
          expect(optimise.slug).to eql('some-optimise-ad-code')
          expect(optimise.campaign).to eql(trump)
        end
      end
    end
  end
end
