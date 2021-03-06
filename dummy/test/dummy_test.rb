require 'test_helper'
require 'pry'

binding.pry
describe TimeMachineBank::HistoricalBank do

  describe 'update_rates' do
    before do
      @bank = TimeMachineBank::HistoricalBank.new
      #@bank.cache = @cache_path
      #@bank.update_rates
      TimeMachineBank::HistoricalBank.configure do |config|
        config.date_format = '%Y-%m-%d'
        config.adapter = :Redis
        config.expires = 1
        config.connection_string = "127.0.0.1:#{ENV["REDIS_PORT"] || 6379}"
      end
    end

    it "should store any rate stored for a date, and retrieve it when asked" do
      d1 = Date.new(2001,1,1)
      d2 = Date.new(2002,1,1)
      @bank.set_rate(d1, "USD", "EUR", 1.234)
      @bank.set_rate(d2, "GBP", "USD", 1.456)

      @bank.get_rate(d1, "USD", "EUR").must_equal 1.234
      @bank.get_rate(d2, "GBP", "USD").must_equal 1.456
    end

    it "shouldn't throw an error when internal_set_rate is called with a non existing currency" do
      d1 = Date.new(2011,1,1)
      @bank.set_rate(d1, "BLA", "ZZZ", 1.01)
      @bank.rates.must_be_empty
    end

    it "should return the correct rate interpolated from existing pairs when asked" do
      d1 = Date.new(2001,1,1)
      @bank.set_rate(d1, "USD", "EUR", 1.234)
      @bank.set_rate(d1, "GBP", "USD", 1.456)

      @bank.get_rate(d1, "EUR", "USD").must_be_within_epsilon 1.0 / 1.234
      @bank.get_rate(d1, "GBP", "EUR").must_be_within_epsilon 1.456 * 1.234
    end

    it "should return the correct rates using exchange_with a date" do
      d1 = Date.new(2001,1,1)
      @bank.set_rate(d1, "USD", "EUR", 0.73062465)
      @bank.exchange_with(d1, Money.new(5000, 'EUR'), 'USD').cents.must_equal 684346
    end
    it "should return the correct rates using exchange_with no date (today)" do
      d1 = Date.today
      @bank.set_rate(d1, "USD", "EUR", 0.8)
      @bank.exchange_with(Money.new(5000, 'EUR'), 'USD').cents.must_equal 625000
    end

  end

  describe 'no rates available yet' do
    before do
      @bank = TimeMachineBank::HistoricalBank.new
      @cache_path = "#{File.dirname(__FILE__)}/test.json"
      ENV['OPENEXCHANGERATES_APP_ID'] = nil
      TimeMachineBank::HistoricalBank.configure do |config|
        config.date_format = '%Y-%m-%d'
        config.adapter = :Redis
        config.expires = 1
        config.connection_string = "127.0.0.1:#{ENV["REDIS_PORT"] || 6379}"
      end
    end

    it 'should download new rates from url' do
      source = TimeMachineBank::OpenExchangeRatesLoader::HIST_URL + '2009-09-09.json'
      stub(@bank).open(source) { File.open @cache_path }
      d1 = Date.new(2009,9,9)

      rate = @bank.get_rate(d1, 'USD', 'EUR')
      rate.must_equal 0.73062465
    end

    describe 'environment variable set with api id' do
      before do
        ENV['OPENEXCHANGERATES_APP_ID'] = 'example-of-app-id'
        TimeMachineBank::HistoricalBank.configure do |config|
          config.date_format = '%Y-%m-%d'
          config.adapter = :Redis
          config.expires = 1
          config.connection_string = "127.0.0.1:#{ENV["REDIS_PORT"] || 6379}"
        end
      end
      it 'should download new rates from url' do
        source = TimeMachineBank::OpenExchangeRatesLoader::HIST_URL + '2009-09-09.json' + '?app_id=example-of-app-id'
        stub(@bank).open(source) { File.open @cache_path }
        d1 = Date.new(2009,9,9)

        rate = @bank.get_rate(d1, 'USD', 'EUR')
        rate.must_equal 0.73062465
      end
    end


  end

  describe 'export/import' do
    before do
      @bank = TimeMachineBank::HistoricalBank.new
      TimeMachineBank::HistoricalBank.configure do |config|
        config.date_format = '%Y-%m-%d'
        config.adapter = :Redis
        config.expires = 1
        config.connection_string = "127.0.0.1:#{ENV["REDIS_PORT"] || 6379}"
      end
    end
    it "should store any rate stored for a date, and retrieve it after importing exported json" do
      d1 = Date.new(2001,1,1)
      d2 = Date.new(2002,1,1)
      @bank.set_rate(d1, "USD", "EUR", 1.234)
      @bank.set_rate(d2, "GBP", "USD", 1.456)

      json = @bank.export_rates(:json)
      @bank.import_rates(:json, json)

      @bank.get_rate(d1, "USD", "EUR").must_equal 1.234
      @bank.get_rate(d2, "GBP", "USD").must_equal 1.456
    end
  end

end
