require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    data = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        "#{table_name}"
    SQL

    data.first.map(&:to_sym)
  end

  def self.finalize!

    columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= name.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |item|
      self.new(item)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    parse_all(data).first
  end

  def initialize(params = {})
    # params.each do |k, v|
    #   raise "unknown attribute '#{k}'" unless self.class.columns.include?(k)
    #   send("#{k}=", v)
    # end
    params.each do |key, value|
      begin
        send("#{key}=", value)
      rescue NoMethodError
        raise "unknown attribute '#{key}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
