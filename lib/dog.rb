
class Dog

    attr_accessor :id, :name, :breed

    def initialize(inputs={})
        inputs.each do |k, v|
            self.send(("#{k}="), v) if self.respond_to?("#{k}=")
        end
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
       DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)     
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
       self
    end

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save
        dog
    end

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = Dog.new(id: id, name: name, breed: breed)
        new_dog
    end

    def self.find_by_id(id)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
        dog = Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            new_dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            new_dog = self.create(name: name, breed: breed)
        end
        new_dog
    end

    def self.find_by_name(name)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name).flatten
        dog = Dog.new(id: result[0], name: result[1], breed: [2])
        dog
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end

end