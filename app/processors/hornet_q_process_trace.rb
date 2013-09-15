class HornetQProcessTrace < TorqueBox::Messaging::MessageProcessor
  def on_message(data)
    ProcessTrace.new.perform(
      data[:uid],
      data[:start],
      data[:trace_session_id]
    )
  end
end
