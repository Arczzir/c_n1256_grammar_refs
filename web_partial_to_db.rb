require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'm2.db',
)


class Ref < ActiveRecord::Base
  self.table_name = "Ref"

  def value2
    value.gsub(/opt\b/, " opt")
  end
end



$refs = []
$ref = nil

def closeRef
  if $ref != nil
    $refs << $ref
    $ref = nil
  end
end

File.readlines('partial.txt').each {|line|
  x = line.match /\A\(6.*?\) (.*?):(.*?)\n/
  if x != nil
    closeRef()
    $ref = Ref.new
    $ref.key_id = x[1]
    if x[2] != nil && x[2] != ""
      $ref.value = x[2].strip
    end
  elsif line.match(/\AContents\n/) != nil
    closeRef()
  else
    if $ref != nil
      v = $ref.value 
      $ref.value = (v == nil ? "" : v + "\n") + line.strip
    end
  end
}


require 'csv'
CSV.open("db.csv", "wb") do |csv|
  $refs.each {|x|
    csv << [x.key_id, x.value2]
    r = Ref.new
    r.key_id = x.key_id
    r.value = x.value2
    r.save
  }
end


