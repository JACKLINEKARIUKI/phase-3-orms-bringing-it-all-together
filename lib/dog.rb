class Dog

    # def initialize(attributes)
    #     attrributes.each do |key, value|
    #         self.class.attr_accessor(key)
    #         self.send(("#{key}="), value)
    #     end
    # end

    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        dog = Dog.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = <<-SQL
            SELECT * FROM dogs
        SQL

        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    # def self.find_or_create_by
    #     sql = <<-SQL
    #         SELECT * FROM dogs WHERE name = ? AND breed = ?
    #     SQL

    #     dog = DB[:conn].execute(sql, self.name, self.breed)

    #     if !dog.empty?
    #         dog_data = dog[0]
    #         dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    #     else
    #         dog = self.create
    #     end
    #     dog
    # end

    # def update
    #     sql = <<-SQL
    #         UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    #     SQL

    #     DB[:conn].execute(sql, self.name, self.breed, self.id)
    # end


end
