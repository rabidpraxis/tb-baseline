class ProcessTrace
  def perform(uid, start, trace_session_id)
    trace          = Trace.new(uid)
    trace_session  = TraceSession.new(trace_session_id)
    trace.duration = DateTime.now.to_f - start

    count = trace_session.current_count.increment
    trace.processed_order = count

    update_stats(trace_session_id) if trace_session.is_final_trace?(count)
  end

  def update_stats(trace_session_id)
    ts = TraceSession.new(trace_session_id)

    time = DateTime.now.to_f
    ts.end_time = time
    ts.avg_per_second = ts.final_count.value.to_f / (time - ts.start_time.value.to_f)

    sleep 2
    # Avg duration
    items = ts.trace_ids.to_a
    vals = Redis.current.multi {items.each {|a| Trace.new(a).duration.value }}.map(&:to_f)
    ts.avg_duration = (vals.sum / vals.size.to_f).round(3)

    # Missed order ct
    vals = Redis.current.multi do
      items.each do |a|
        tr = Trace.new(a)
        tr.insert_order.value
        tr.processed_order.value
      end
    end.each_slice(2).to_a

    ts.missed_order_count = vals.select {|a| a[0] != a[1]}.length
  end
end
