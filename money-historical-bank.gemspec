Gem::Specification.new do |s|
  s.name = "money_historical_bank"
  s.version = "0.0.3"
  s.date = Time.now.utc.strftime("%Y-%m-%d")
  s.homepage = "https://github.com/atwam/#{s.name}"
  s.authors = "atwam"
  s.email = "wam@atwam.com"
  s.description = "A gem that provides rates for the money gem. Able to handle history (rates varying in time), and auto download rates from open-exchange-rates. Highly inspired by money-open-exchange-rates gem."
  s.summary = "A gem that offers exchange rates varying in time."
  s.extra_rdoc_files = %w(README.markdown)
  #s.files = Dir["LICENSE", "README.markdown", "Gemfile", "lib/**/*.rb", 'test/**/*']
  s.files = Dir["lib/time_machine_bank.rb"]
  s.test_files = Dir.glob("test/*_test.rb")
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.add_dependency "yajl-ruby", ">=0.8.3"
  s.add_dependency "money", ">=3.7.1"
  s.add_development_dependency "minitest", ">=2.0"
  s.add_development_dependency "rr", ">=1.0.4"
  s.add_development_dependency "moneta", "~> 0.8"
  s.add_development_dependency "hashie"
  s.add_development_dependency "redis", '~>3.2' 
end
