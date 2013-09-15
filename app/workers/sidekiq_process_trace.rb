require 'lib/process_trace'

class SidekiqProcessTrace
  include Sidekiq::Worker

  def perform(data)
    ProcessTrace.new.perform(
      data['uid'],
      data['start'],
      data['trace_session_id']
    )
  end
end
