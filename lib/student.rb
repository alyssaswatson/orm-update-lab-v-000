require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @name = name
    @id = id
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(student_array)
    id = student_array[0]
    name = student_array[1]
    grade = student_array[2]
    self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT name
      FROM students
      WHERE name
      IS ?
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

end
