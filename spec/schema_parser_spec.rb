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

    it "outputs the week numbers of A weeknight classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("A").weeknight_weeks).to be_empty
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

    it "outputs the week numbers of A weekend classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("A").weekend_weeks).to be_empty
    end
  end

  describe "#parse#weeknight_dates" do
    it "outputs the week numbers of GK1 weeknight classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("GK 1").weeknight_dates).to eq(["20 jan.", "27 jan.", "03 feb.", "10 feb.", "17 feb."])
    end

    it "outputs the week numbers of GK2 weeknight classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("GK 2").weeknight_dates).to eq(["24 feb.", "03 mars", "10 mars", "17 mars", "24 mars"])
    end

    it "outputs the week numbers of M2 weeknight classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("M 2").weeknight_dates).to eq(["19 feb.", "26 feb.", "05 mars", "12 mars", "19 mars"])
    end

    it "outputs the week numbers of A weeknight classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("A").weeknight_dates).to be_empty
    end
  end

  describe "#parse#weekend_dates" do
    it "outputs the week numbers of GK1 weekend classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("GK 1").weekend_dates).to eq(["25 jan.", "26 jan."])
    end

    it "outputs the week numbers of GK2 weekend classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("GK 2").weekend_dates).to eq(["22 feb.", "23 feb."])
    end

    it "outputs the week numbers of M2 weekend classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("M 2").weekend_dates).to be_empty
    end

    it "outputs the week numbers of A weekend classes" do
      parser = described_class.new

      result = parser.parse(ht24_vt25_file_path)

      expect(result.fetch("A").weekend_dates).to be_empty
    end
  end

  def ht24_vt25_file_path
    "spec/fixtures/Schema kurser HT24-VT25 - Stora salen 24_25.csv"
  end
end
