require 'sidekiq/limiter/version'

module Sidekiq
  module Middleware
    module Server
      class Limiter
        include Sidekiq::Util

        DEFAULT_INTERVAL = 5

        def initialize(options = {})
          @queues = Sidekiq.options[:process_limits]
          @interval = options.fetch(:interval, DEFAULT_INTERVAL)
        end

        def call(worker, msg, queue)
          if @queues[queue] && is_busy?
            Sidekiq::Client.push('queue' => queue, 'class' => worker.class.name, 'args' => msg['args'],
                                 'at' => (Time.now + @interval).to_f)
          else
            yield
          end
        end

        def is_busy?
          Sidekiq.redis do |conn|
            workers_count = conn.smembers('workers').count do |w|
              next unless w =~ /^#{hostname}/

              options = conn.get("worker:#{w}")
              next unless options

              options = Sidekiq.load_json(options)
              @queues[options['queue']]
            end

            workers_count >= 2
          end
        end
      end
    end
  end
end