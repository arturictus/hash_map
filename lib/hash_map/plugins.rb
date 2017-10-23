module HashMap
  BlankToNil = lambda do |v|
    Fusu.blank?(v) ? nil : v
  end

  StringToBoolean = lambda do |v|
    return false if v == 'false'
    return true if v == 'true'
    v
  end

  UnderscoreKeys = lambda do |output|
    Fusu::Hash.deep_transform_keys(output){ |k| Fusu::String.underscore(k).to_sym }
  end
end
