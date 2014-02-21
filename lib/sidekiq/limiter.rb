require 'sidekiq/limiter/version'

module Sidekiq
  module Middleware
    module Server
      class Limiter
        include Sidekiq::Util

        DEFAULT_INTERVAL = 5

        def initialize(options = {})
          @queue = options[:queue] || Sidekiq.options[:limiter]
          @interval = options.fetch(:interval, DEFAULT_INTERVAL)
        end

        def call(worker, msg, queue)
          puts "@queue = #{@queue} #{queue} #{queue == @queue} #{!can_start?}"
          if queue == @queue && !can_start?
            Sidekiq::Client.push('queue' => queue, 'class' => worker.class.name, 'args' => msg['args'],
                                 'at' => (Time.now + @interval).to_f)
          else
            yield
          end
        end

        def can_start?
          Sidekiq.redis do |conn|
            workers_count = conn.smembers('workers').count do |w|
              next unless w =~ /^#{hostname}/

              options = conn.get("worker:#{w}")
              next unless options

              options = Sidekiq.load_json(options)
              options['queue'] == @queue
            end

            workers_count < 2
          end
        end
      end
    end
  end
end