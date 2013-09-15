class TraceGlobal
  include Redis::Objects
  def id; 'global'; end

  list :sessions
end
