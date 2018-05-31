require 'sidekiq'
puts "req!"

class SampleWorker
  include Sidekiq::Worker

  def perform
    puts "Workin' hard!"
  end
end
