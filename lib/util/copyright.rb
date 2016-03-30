class Copyright
  MARKERS_TEMPLATES = [
    /<metadata>copyright[\s+]\(c\)[\s+][\d]{4}[\s+]by([^-]+)<\/metadata>/i,
    /copyright[\s+]\(c\)[\s+][\d]{4}[\s+]by([^-]+)/i,
    /copyright[\s+][\d]{4}-[\d]{4}[\s+]([^-]+)or[\s+]its[\s+]affiliates./i,
    /copyright[\s+][\d]{4}-[\d]{4}[\s+]([^-]+)All[\s+]Rights[\s+]Reserved./i,
    /copyright[\s+]\(c\)[\s+][\d]{4}-[\d]{4}[\s+]by([^-]+)/i,
    /Copyright[\s?]&copy;[\s+][\d]{4}[\s+]([^-]+)[\s+]All[\s+]rights[\s+]reserved/i,
    /Copyright&copy;[\s+][\d]{4}[\s+]([^-]+)[\s+]All[\s+]rights[\s+]reserved/i,
    /copyright[\s+]©[\s+]All[\s+]Rights[\s+]Reserved,([^-]+)/i,
    /copyright[\s+]\(c\)[\s+][\d]{4}[\s+]by[\s+]([^-]+)/i,
    /copyright&copy;[\s+][\d]{4}[\s+]([^-]+)/i,
    /copyright[\s+]&copy;[\s+][\d]{4}[\s+]([^-]+)/i,
    /copyright[\s+][\d]{4}[\s+]([^-]+)/i,
    /copyright[\s+]\(c\)[\s+][\d]{4},[\s+][\d]{4}[\s+]([^-]+)/i,
    /copyright[\s+]\(c\)[\s+][\d]{4}[\s+]by[\s+]([^-]+ LLC)/i,
    /copyright[\s+]\(c\)[\s+][\d]{4}[\s+]([^-]+ LLC)[\s+]-[\s+]all[\s+]rights[\s+]reserved[\s+]/i,
    /copyright[\s+][\d]{2,4}[\s+]([^-]+)/i,
    /field key="copyright"[\s+]value=\"\(c\)[\s+]([^-]+)[\s+][\d]{4}\"/i,
    /field key="copyright"[\s+]value=\(c\)[\s+]([^-]+)\/>/i,
    /field key="copyright"[\s+]value=([^-]+)\/>/i,
    /<copyright>\(c\)[\s+]([^-]+)<\/copyright>/i,
    /<copyright>([^-]+)<\/copyright>/i,
    /copyright[\s+][\d]{4}\-[\d]{4}[\s+]([^-]+)/i,
    /copyrights[\s+]\(c\)[\s+][\d]{4}\-[\d]{4}\.[\s+]([^-]+)[\s{2}]/i,
    /copyrights[\s+]\(c\)[\s+][\d]{4}\-[\d]{4}\.[\s+]([^-]+)/i,
    /copyrights[\s+]\(c\)[\s+][\d]{4}\-[\d]{4}([^-]+)/i,
    /copyright[\s+][\d]{4}\,([^-]+)/i,
    /copyright[\s+]©[\d]{4}([^-]+)[\s+]\</i,
    /copyright[\s+]©[\d]{4}([^-]+)/i,
    /\(c\)[\s+][\d]{4}-[\d]{4}[\s+]([^-]+)/i,
    /copyright[\s+]\(c\)[\s+][\d]{4}-[\d]{4}[\s+]by[\s+]t([^-]+)/i,
    /\/\/[\s+][\d]{4}[\s+]\(c\)[\s+]-[\s+]([^-]+)/i,
    /\(c\)[\s+][\d]{4}-[\d]{4}([^-]+)[\s{2}]/i,
    /\(c\)[\s+][\d]{4}-[\d]{4}([^-]+)/i,
    /\(c\)[\s+][\d]{4}([^-]+)[\s+]\(/i,
    /\(c\)[\s+][\d]{4}([^-]+)/i,
    /©[\s+]copyright[\s+]([^-]+)[\s+][\d]{4}/i
  ]

  REMOVAL_MARKERS = [
    /^,/,
    /all[\s+]rights[\s+]reserved.*/i,
    /\\n.*/,
    /\|.*/,
    /[\s{4}]\*$/
  ]

  def self.find_owner(line)
    file, message = line.split(":", 2).first, line.split(":", 2).last
    [detect_owner(message), file]
  end

  private

  def self.detect_owner(message)

    MARKERS_TEMPLATES.each_index do |index|
      if m = message.match(MARKERS_TEMPLATES[index])
        owner = m.captures.compact.first
        REMOVAL_MARKERS.each do |marker|
          owner = owner.gsub(marker, '')
        end
        if owner.strip.length > 2 and owner.strip.length < 20
          return owner.strip
        end
      end
    end

    ''
  end
end
