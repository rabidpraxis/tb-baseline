Redis.current = Redis.new({ host: Rails.configuration.settings[:redis][:host],
                            port: Rails.configuration.settings[:redis][:port] })
