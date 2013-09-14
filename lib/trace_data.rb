class Trace
  include Redis::Objects

  value :start_time
  value :duration
end
