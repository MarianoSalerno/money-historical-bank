# encoding: UTF-8
require 'money'
require 'date'
require 'yajl'
require 'open-uri'

class Money
  module TimeMachineBank
    module OpenExchangeRatesLoader
      HIST_URL = 'http://openexchangerates.org/api/historical/'
      OER_URL = 'http://openexchangerates.org/api/latest.json'

      # Tries to load data from OpenExchangeRates for the given rate.
      # Won't do anything if there's no data available for that date
      # in OpenExchangeRates (short) history.
      def load_data(date)
        date = date.to_date
        date_formated = date.strftime(Money::TimeMachineBank::HistoricalBank.config.date_format)
        cache = Moneta.new(:Redis, server: "127.0.0.1:6379")
        rates_source = if date == Date.today
                         OER_URL.dup
                       else
                         HIST_URL + date_formated + '.json'
                       end
        rates_source << "?app_id=#{ENV['OPENEXCHANGERATES_APP_ID']}" if ENV['OPENEXCHANGERATES_APP_ID']
        doc = Yajl::Parser.parse(open(rates_source).read)

        base_currency = doc['base'] || 'USD'

        doc['rates'].each do |currency, rate|
          # Don't use set_rate here, since this method can only be called from
          # get_rate, which already aquired a mutex.
          internal_set_rate(date, base_currency, currency, rate)
          Money::TimeMachineBank::HistoricalBank.store(Money::TimeMachineBank::HistoricalBank.build_key(date, base_currency, currency), rate)
        end
      end
    end
  end
end
