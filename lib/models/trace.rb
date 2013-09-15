class Trace < Base
  include Redis::Objects

  value :insert_order
  value :processed_order

  value :start_time
  value :duration
end
