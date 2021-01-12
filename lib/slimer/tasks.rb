# frozen_string_literal: true

require "rake"

# Initialize the DB
Slimer.db
Dir.glob("#{__dir__}/tasks/*.rake") do |rake_file|
  load rake_file
end
