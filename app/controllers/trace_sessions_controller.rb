class TraceSessionsController < ApplicationController
  def index
    ses_ids  = TraceGlobal.new.sessions.to_a
    ses_data = redis.multi do
      ses_ids.each do |s_id|
        ts = TraceSession.new(s_id)
        ts.start_time.value
        ts.avg_duration.value
        ts.avg_per_second.value
        ts.load_per_second.value
        ts.missed_order_count.value
        redis.get(ts.current_count.key) # Required for counters
        ts.final_count.value
        ts.extra_data.value
      end
    end.each_slice(8)
    @sessions = ses_ids.zip(ses_data.to_a).map(&:flatten)
  end

  # Start load session
  #
  # count
  # session_name
  #
  def create
    create_start = Time.now.to_f

    ct   = params[:trace_sessions][:count].to_i
    name = rand(36**4).to_s

    TraceGlobal.new.sessions << name
    ts = TraceSession.new(name)

    ts.start_time = Time.now.to_f
    ts.final_count = ct


    counter = 0
    trace_ids = ct.times.each_with_object([]) do |i, coll|
      start = Time.now.to_f
      # Create unique id
      uid   = "#{rand(36**4)}-#{start}"

      trace = Trace.new(uid)

      trace.start_time   = start
      trace.insert_order = counter += 1

      coll << uid

      data = {
        'trace_session_id' => name,
        'uid' => uid,
        'start' => start
      }

      TorqueBox::Messaging::Queue.new('/queues/trace').publish(
        data,
        encoding: :json
      )
      # SidekiqProcessTrace.perform_async(data)
    end

    redis.multi do
      trace_ids.each {|id| ts.trace_ids << id}
    end

    ts.extra_data = "HornetQ - json - concurrency 40"
    ts.load_per_second = ct / (Time.now.to_f - create_start)

    redirect_to trace_sessions_path
  end

  def destroy
    ses_id = params[:id]
    TraceGlobal.new.sessions.delete(ses_id)
    TraceSession.new(ses_id).delete

    redirect_to trace_sessions_path
  end
end
