# frozen_string_literal: true

require "app/schema_parser/date_parser"

RSpec.describe SchemaParser::DateParser do
  describe "#parse" do
    context "when the date is in Februrary" do
      it "parses it to a date in the given year" do
        parser = described_class.new

        expect(parser.parse("25 feb.", year: 2021)).to eq(Date.parse("2021-02-25"))
      end
    end

    context "when the date is in May" do
      it "parses it to a date in the given year" do
        parser = described_class.new

        expect(parser.parse("25 maj", year: 2021)).to eq(Date.parse("2021-05-25"))
      end
    end

    context "when the month was not recognised" do
      it "raises" do
        parser = described_class.new

        expect do
          parser.parse("25 ax.", year: 2021)
        end.to raise_error(KeyError, 'key not found: "ax."')
      end
    end
  end
end
