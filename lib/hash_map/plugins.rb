module HashMap
  BlankToNil = lambda do |v, ctx|
    Fusu.blank?(v) ? nil : v
  end

  StringToBoolean = lambda do |v, ctx|
    return false if v == 'false'
    return true if v == 'true'
    v
  end

  MarkUnprovided = lambda do |v, ctx|
    if !ctx.provided?
      KeyNotProvided.new
    else
      v
    end
  end

  RemoveUnprovideds = lambda do |o|
    HashMap.deep_reject(o){ |k, v| v.is_a?(HashMap::KeyNotProvided) }
  end

  UnderscoreKeys = lambda do |output|
    Fusu::Hash.deep_transform_keys(output){ |k| Fusu::String.underscore(k).to_sym }
  end
end
