TorqueBox.configure do
  pool :web,        :type => :shared
  pool :messaging,  :type => :shared,  :lazy => false

  queue '/queues/trace' do
    processor HornetQProcessTrace do
      concurrency 12
    end
  end
end

