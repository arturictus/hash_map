module HashMap
  BlankToNil = lambda do |v|
    v.blank? ? nil : v
  end

  StringToBoolean = lambda do |v|
    return false if v == 'false'
    return true if v == 'true'
    v
  end

  UnderscoreKeys = lambda do |output|
    output.deep_transform_keys{ |k| k.underscore.to_sym }
  end
end
