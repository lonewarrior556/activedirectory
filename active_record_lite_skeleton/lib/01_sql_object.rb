require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.
class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end


class SQLObject

  def self.columns
    if @columns.nil?
      set = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
      SQL
      @columns = set.first.map{|x| x.to_sym}
    else
      @columns
    end
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        self.attributes[column]
      end
      define_method((column.to_s+"=").to_sym) do |block|
        self.attributes[column] = block
      end
    end


  end

  def self.table_name=(table_name)
    @table_name = table_name
    @column = nil
  end

  def self.table_name
    @table_name = self.to_s.underscore+"s" if @table_name.nil?
    @table_name
  end

  def self.all
    @all = DBConnection.execute(<<-SQL)
      SELECT
      #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL
    self.parse_all(@all)
  end

  def self.parse_all(results)
    ls = []
    results.each do |hash|
      ls << self.new(hash)
    end
    ls
  end

  def self.find(id)
    obj = DBConnection.execute(<<-SQL, id)
      SELECT
      #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    self.parse_all(obj)[0]
  end

  def initialize(params = {})
    params.keys.each do |key|
      raise Exception, "unknown attribute '#{key}'" if !self.class.columns.include?(key.to_sym)
    end
    @attributes = Hash.new
    params.keys.each do |key|
      self.send((key.to_s+"=").to_sym,params[key])
    end
  end


  def attributes
    @attributes
  end

  def attribute_values
    self.attributes.values
  end

  def insert
    col_names = self.class.columns[1..-1].join(',')
    q_marks = (['?']*self.class.columns.length)[1..-1].join(',')
    values = self.attribute_values


    DBConnection.execute(<<-SQL, *values )
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{q_marks})
    SQL

    self.id = DBConnection.last_insert_row_id

  end

  def update

    values = attributes.dup
    values.delete(:id)
    values = values.to_s.gsub(":","").gsub(">","").gsub("\"","'").

    DBConnection.execute(<<-SQL, *values )
      UPDATE
        #{self.class.table_name}
      SET
        #{values}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    # ...
  end



end
