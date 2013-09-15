class TraceSession < Base
  include Redis::Objects

  list :trace_ids

  value :start_time
  value :end_time
  value :avg_per_second

  value :avg_duration

  value :load_per_second

  value   :missed_order_count
  value   :final_count
  counter :current_count

  value :extra_data, marshal: true

  def is_final_trace?(count)
    count == final_count.value.to_i
  end

  def delete
    ids = self.trace_ids.to_a

    Redis.current.multi do
      ids.each {|id| Trace.new(id).delete }
    end

    super
  end
end
