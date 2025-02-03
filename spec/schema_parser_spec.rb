# frozen_string_literal: true

require "app/schema_parser"

RSpec.describe SchemaParser do
  describe "#parse#weeknight_weeks" do
    it "outputs the week numbers of GK1 weeknight classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("GK 1").weeknight_weeks).to eq((4..8).to_a)
    end

    it "outputs the week numbers of GK2 weeknight classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("GK 2").weeknight_weeks).to eq((9..13).to_a)
    end

    it "outputs the week numbers of M2 weeknight classes (ids are different because of themes)" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("M 2").weeknight_weeks).to eq((8..12).to_a)
    end
  end

  describe "#parse#weekend_weeks" do
    it "outputs the week numbers of GK1 weekend classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("GK 1").weekend_weeks).to eq([4])
    end

    it "outputs the week numbers of GK2 weekend classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("GK 2").weekend_weeks).to eq([8])
    end

    it "outputs the week numbers of M2 weekend classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("M 2").weekend_weeks).to be_empty
    end
  end

  def ht24_vt25_file_path
    "spec/fixtures/Schema kurser HT24-VT25 - Stora salen 24_25.csv"
  end
end
