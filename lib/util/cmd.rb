module Cmd
  def arg(name)
    @args.each do |a|
      key, val = a.split('=')
      next unless key == name
      return val
    end
    nil
  end

  def array_arg(str, default)
    split_with_default(arg(str), default)
  end

  def split_with_default(str, default)
    str.split(',') rescue default
  end
end
