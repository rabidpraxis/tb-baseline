class ApplicationController < ActionController::Base
  protect_from_forgery

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def redis
    Redis.current
  end
end
