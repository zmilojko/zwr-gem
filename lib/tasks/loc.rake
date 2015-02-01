namespace :loc do
  def extract_from(folder, list)
    Dir.entries(folder).each do |fof|
      if File.directory?(fof_full = File.join(folder,fof)) and fof !='.' and fof != '..'
        extract_from fof_full, list
      else
        if File.extname(fof_full) == ".haml"
          File.open(fof_full).read().scan(/=t :'(.+)'(\s*#\s*(.+))?/) do |match|
            sym = match[0]
            # Do not add multiple items, even if default translation (as comment) differs
            if list.none? { |x| x[0] == sym }
              list << [sym, %{  "#{sym}":}.ljust(30) + %{"#{match[2] || match[0]}"}]
            end
          end
        end
      end
    end
  end
  
  desc "extracts all localized strings from all HAML files"
  task :extract do
    list = []
    extract_from Rails.root, list
    list.each { |x| puts x[1] }
  end
end