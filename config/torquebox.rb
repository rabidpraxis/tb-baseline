TorqueBox.configure do
  pool :web,        :type => :shared
  pool :jobs,       :type => :shared,  :lazy => false
  pool :messaging,  :type => :shared,  :lazy => false
  pool :services,   :type => :shared,  :lazy => false

  queue '/queues/identity' do
  end
end

