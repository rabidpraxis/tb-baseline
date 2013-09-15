class Base
  attr_accessor :id

  def initialize(id)
    @id = id
  end

  def delete_key(key)
    key_str = self.send(key.to_sym).key
    redis.del(key_str)
  end

  # Accounts for Value and Sets
  # TODO: accomidate more types
  def delete
    self.class.redis_objects.each do |key, obj|
      obj = self.send(key.to_sym)
      if obj.class == Redis::Set || obj.class == Redis::HashKey || obj.class == Redis::List
        delete_key(key)
      else
        obj.delete
      end
    end
  end
end
