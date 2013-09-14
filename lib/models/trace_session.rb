class TraceSession < Base
  include Redis::Objects

  list :session_ids

  value :session_start
  value :session_end

  value :extra_data, marshal: true
end
