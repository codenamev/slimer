# frozen_string_literal: true

namespace :slimer do
  namespace :api_keys do
    desc "Generate a Slimer API key"
    task :generate do
      name = loop do
        puts "Enter a name for this API key: "
        new_name = $stdin.gets.chomp
        break new_name unless new_name.to_s.empty?

        puts "You must enter a name for this API key."
      end

      puts "Your new Slimer API key for \"#{name}\": #{Slimer::ApiKey.generate(name).token}"
    end
  end
end
