class Captain < ActiveRecord::Base
  has_many :boats

  def self.catamaran_operators  # => <Captain::ActiveRecord_Relation>
    # Captain.joins(:boat).where(boats: {classification_id: cat_class.id}) # empty    
    # Captain.joins(:boat => :classification).where(boats: {classification: {id: cat_class.id}}) # empty

    cat_class = Classification.find_by(name: "Catamaran")
    c = Captain.joins("""
      INNER JOIN boats ON boats.captain_id = captains.id 
      INNER JOIN boat_classifications ON boats.id = boat_id 
      WHERE classification_id=#{cat_class.id}
      """)

    Captain.includes(boats: :classifications).where(classifications: {name: "Catamaran"})
  end

  def self.sailors
    Captain.includes(boats: :classifications).where(classifications: {name: "Sailboat"}).uniq
  end
  
  def self.motorboaters
    Captain.includes(boats: :classifications).where(classifications: {name: "Motorboat"}).uniq
  end

  # returns captains of motorboats and sailboats
  def self.talented_seafarers 
    Captain.where("id IN (?)", self.sailors.pluck(:id) & self.motorboaters.pluck(:id))
  end
  
  # returns people who are not captains of sailboats
  def self.non_sailors
    Captain.where.not("id IN (?)", self.sailors.pluck(:id))
  end

end
