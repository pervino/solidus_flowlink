require 'spree/flowlink'

namespace :flowlink do
  desc 'Push batches to Flowlink'
  task :push_it => :environment do

    if Spree::Flowlink::Config[:connection_token] == "YOUR TOKEN" || Spree::Flowlink::Config[:connection_id] == "YOUR CONNECTION ID"
      abort("[ERROR] It looks like you did not add your Flowlink credentails to config/intializers/flowlink.rb, please add them and try again. Exiting now")
    end
    puts "\n\n"
    puts "Starting pushing objects to Flowlink"
    Spree::Flowlink::Config[:push_objects].each do |object|
      objects_pushed_count = Spree::Flowlink::Client.push_batches(object)
      puts "Pushed #{objects_pushed_count} #{object} to Flowlink"
    end
  end
end
