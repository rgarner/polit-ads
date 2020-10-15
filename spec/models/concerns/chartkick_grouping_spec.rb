require 'rails_helper'

RSpec.describe ChartkickGrouping do

  describe '#group_for_chartkick' do
    let(:rows) {
      [
        { 'value' => 'v1', 'value_name' => 'n1', 'start' => 'st1', 'count' => 1, 'approximate_spend' => 5 },
        { 'value' => 'v2', 'value_name' => 'n2', 'start' => 'st2', 'count' => 2, 'approximate_spend' => 6 },
        { 'value' => 'v3', 'value_name' => 'n3', 'start' => 'st3', 'count' => 3, 'approximate_spend' => 7 },
        { 'value' => 'v3', 'value_name' => 'n3', 'start' => 'st4', 'count' => 4, 'approximate_spend' => 8 }]
    }

    class Grouper
      include ChartkickGrouping
    end

    context 'no dimension is given' do
      subject(:grouped) { Grouper.group_for_chartkick(rows) }

      it 'groups by value' do
        expect(grouped).to eql(
          [
            { data: [['st1', 1]], name: 'v1' },
            { data: [['st2', 2]], name: 'v2' },
            { data: [['st3', 3], ['st4', 4]], name: 'v3' }
          ]
        )
      end

      context 'and value_name is included at series-level' do
        subject(:grouped) { Grouper.group_for_chartkick(rows, include: %w[value_name]) }

        it 'groups and includes value_name' do
          expect(grouped).to eql(
            [
              { data: [['st1', 1]], name: 'v1', value_name: 'n1' },
              { data: [['st2', 2]], name: 'v2', value_name: 'n2' },
              { data: [['st3', 3], ['st4', 4]], name: 'v3', value_name: 'n3' }
            ]
          )
        end
      end
    end

    context 'dimension is spend' do
      subject(:grouped) { Grouper.group_for_chartkick(rows, dimension: 'approximate_spend') }

      it 'groups by spend' do
        expect(grouped).to eql(
          [
            { data: [['st1', 5]], name: 'v1' },
            { data: [['st2', 6]], name: 'v2' },
            { data: [['st3', 7], ['st4', 8]], name: 'v3' }
          ]
        )
      end
    end
  end
end
