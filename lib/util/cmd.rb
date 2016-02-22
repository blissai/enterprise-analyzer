module Cmd
  def arg(name)
    conf = nil
    @args.each do |a|
      key, val = a.split('=')
      next unless key == name
      conf = val
      break
    end
    conf
  end
end
