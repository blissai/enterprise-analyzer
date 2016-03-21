class StatsMerger
  def initialize(clocs)
    update_clocs(clocs)
  end

  def update_clocs(clocs)
    @clocs = []
    clocs.each do |cloc|
      @clocs.push(YAML.load(cloc))
    end
  end

  def merge_files
    @all_keys = all_keys
    setup_base
    @clocs.each do |cloc|
      cloc.each do |k, v|
        next if k == 'header'
        merge_language_counts(k, v)
      end
    end
    @result
  end

  private

  def setup_base
    @result = {}
    @all_keys.each do |k|
      next if k == 'header'
      @result[k] = {
        'nFiles' => 0,
        'blank' => 0,
        'comment' => 0,
        'code' => 0
      }
    end
  end

  def merge_language_counts(language, language_cloc)
    language_cloc.each do |k, v|
      @result[language][k] += v
    end
  end

  def all_keys
    keys = []
    @clocs.each do |cloc|
      cloc.keys.each do |k|
        keys.push(k) unless keys.include?(k)
      end
    end
    keys
  end
end
