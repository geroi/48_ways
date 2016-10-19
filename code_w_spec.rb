require 'rspec'

# Item 1
# All is true except false and nil

# Item 2
RSpec.describe do
  before do
    @ary = [1,2,nil,nil,3,4]
  end
  it 'clear nils' do
    expect(@ary.compact.any? {|e| e.nil?}).to be_false 
  end
end
# any_object.nil?
# nil.to_s
# .to_a
# .to_i
# Array.compact #kills all nil

# Item 3
# Prefer str.match to =~

# Item 4
CONSTANTS.freeze #beacuse consant are mutable

# Item 5
# ruby -w #enable warnings

# Item 6
# No Module.new
# singleton_class
# singleton_methods
# В поиске етода идет вверх по иерархии
# Если не находит, ищет method_missing, потом Kernel.method_missing
# Когда делаем include ModuleName - ModuleName превращается в singleton (анонимный и невидимый) суперкласс и встает
# между классом и суперклассом
class Customer < Person # Customer < MethodName(anonymous and invisible) < Person
  include MethodName
end

customer = Customer.new
def customer.meth; end # singleton метод для инстанса

#метод класса - синглтон метод
class Klass
  def self.meth_name #singlton method
  end
end

# Item 7
# super #вызывает аналогичный метод суперкласса c передачей всех переменных в этом методе

# super вызывается из первого по иерархии старшего класса (в т.ч. Синглтон класса - если include or smth)

# Item 7
class Human
  def initialize name
    @name = name
  end
end

class Person < Human
  def initialize name, age
    super name
    @age = age
  end
end

#item 9
# self.counter = 9 # для сеттеров неплохо использовать селф, можно запихнуть валидацю в .counter= метод

#Item 10
# Use structs for data structures insted of Hash. Easy to add methods/ Has to_h method
# Присваивай константам значения Структов типа SETTINGS = Settings.new()
Tick = Struct.new(:high, :low, :volume) do
  def mean
   ( high + low ) / 2.0
  end
end
Tick.new()

# Item 11 - выделяйте пространство имен
# по папкам раскладывать как method_man/notebook/bindings.rb
module MethodMan
  module Notebook
    class Bindings; end
  end
end

# Константы ищутся иначе чем методы
# Для констант есть лекические пространства, которые нужно точно указывть
SETTINGS = {a: 1, b: 2}
module Cluster
  SETTINGS = []
  class Array
    def initialize (n)
      @disks = ::Array.new(n) {|i| "disk#{i}"} # Иначе Array вызовется из того же модуля.
      @settings = SETTINGS# для поиска в глобальном пространстве следует ::Constant
      @global_settings = ::SETTINGS
    end
  end
end
# Notebook - пространство имен

#Item 12 COMPARABLE
# Чтобы сравнивать , нужно написать метод <=>
# <=> возвращает -1, 0, 1, nil если левый больше правого, если равны, если правй больше, если несравнимо
# def <=> (other)
#   return nil unless other.is_a?(Version)

#   [ major <=> other.major,
#     minor <=> other.minor,
#     patch <=> other.patch,
#   ].detect {|n| !n.zero?} || 0
# end

# include Comparable #добавляет варианты >=, <=

#Item 14

# private методы нельзя вызвать извне
# protected методы можно вызывать представителями класса и подклассв


class Widget
  protected
    def coords
      [x,y]
    end
end
class Window < Widget
end
class Application 
end

###############################################
module Item14
  class Widget
    protected
    def coords;end
  end
  class Window < Widget; end
  class Application; end
end

RSpec.describe Item14 do 
  let(:not_same_class_sending) do
    class Item14::Application
      def call_coords obj
        obj.coords
      end
    end
    Item14::Application.new.call_coords Item14::Window.new
  end

  let(:same_class_sending) do
    class Item14::Window
      def call_coords obj
        obj.coords
      end
    end
    Item14::Window.new.call_coords Item14::Window.new
  end

  let(:subclass_sending) do
    class Item14::Widget
      def call_coords obj
        obj.coords
      end
    end
    Item14::Widget.new.call_coords Item14::Window.new
  end

  context "when sending method from the OTHER class" do
    it "should raise NME" do
      expect{ not_same_class_sending }.to raise_error NoMethodError
    end
  end

  context "when sending method from SAME class" do
    it "should accept it" do
      expect{ same_class_sending }.not_to raise_error 
    end
  end

  context "when sending method from subclass" do
    it "should accept it" do
      expect{ subclass_sending }.not_to raise_error 
    end
  end
end
###################################################
# Item 15
# Prefer Class Instance variables to Class variables
module Item15
  class Klass
    @@info
    def self.info
      @@info
    end

    def self.info= info
      @@info = info
    end
  end

  class NewKlass < Klass
  end

  class SecNewKlass < Klass
  end
end

RSpec.describe Item15  do  
  it "Class variables will be the only one for all classes" do
    Item15::Klass.info = "string"
    Item15::NewKlass.info = "second string"
    Item15::SecNewKlass.info = "third string"
    expect(Item15::Klass.info).to eq(Item15::NewKlass.info).and eq("third string")
  end
end

#########################################################3
## You should clone the collection you are passing to the method
## Clone, not .dup because of clone respect to frozen state and singleton_methods within 
## Especially arrays or hashes
## Often methods mutate the original array
## Because passing reference nor copy/object
module Item15
  class Klass
    def initialize collection
      @collection = collection.clone
    end
  end
end

###########################################################
# Item 16
# Array() method
# Integer() method
# String() method

###########################################################33
# Use Set - UNORDERED array of UNIQUE
# Set is fast in .include? method

require 'set'
module Item 18
  class AnnualWeather
    Reading = Struct.new(:date, :high, :low) do
      def eql? (other) date.eql?(other.date); end
      def hash; date.hash; end
    end
    def initialize (file_name)
      @readings = Set.new
      CSV.foreach(file_name, headers: true) do |row|
        @readings << Reading.new(Date.parse(row[2]),
                                 row[10].to_f,
                                 row[11].to_f)
      end
    end
  end
end

#######################################################
# Item 19 
# reduce 
# Always return accumulator from block!
#
module Item19
  NAMES = %w( Alex Gena Kolya Vova).freeze
  User = Struct.new(:name,:drunk) do
    def drunk?
      !!drunk
    end
  end

  module_function
  
  def meth
    users.reduce([]) do |names, user|
      names << user.name if user.age >= 21
      names # обязательно к возврату из reduce
    end
  end

  def random_drunk_state
    rand(0..1) > 0
  end

  def users
    NAMES.reduce([]) { |users, name|
      users << User.new(name, random_drunk_state)
      users
    }
  end
# Константы ищутся иначе чем методы
# Для констант есть лекические пространства, которые нужно точно указывть

  def drunk_users
    users.reduce([]) { |drunk_users, user|
      drunk_users << user if user.drunk?
      drunk_users
    }
  end
end

########################################################
# Should prefer delegation from 
# inheriting from collection classes
# 
module Item21
  require 'forwardable'
  class FuckError < StandardError; end
  class Storage
    extend Forwardable

    def initialize hash
      @hash_data = hash if hash.is_a? Hash
    end

    def inspect
      @hash_data
    end

    def_delegator :@hash_data, :fetch
    def_delegator :@hash_data, :length, :quantity
  end
end

RSpec.describe Item21 do

  let(:storage) { Item21::Storage.new({a: 1, b: 2}) } 

  it 'fetches key' do
    expect{ storage.fetch(:a) }.not_to raise_error
  end

  it 'responds to quantity' do
    expect(storage).to respond_to(:quantity)
  end

  it 'has no Hash methods' do
    expect{ storage.key?(:a) }.to raise_error NoMethodError
  end
end

#######################################################
# Raise custom Exception
module Item 22
  class CoffeMachineOutOfWater < StandardError; end
end
# raise CoffeMachineOutOfWater, "Water level too low"


########################################################
# Rescue the most specific Exception
# Rescue only those specific exceptions from which you know how to recover
# When rescuing an exception, handle the most specific type first. The higher a class is in the exception hierarchy the lower it should be in your chain of rescue clauses.
# Avoid rescuing generic exception classes such as StandardError. If you find yourself doing this you should consider if what you really want instead is an ensure clause.
# Raising an exception from a rescue clause will replace the current exception and immediately leave the current scope, resuming exception processing.

begin
  task.perform
rescue NetworkConnectionError => e
  # Retry logic...
rescue InvalidRecordError => e
  # Send record to support staff...
rescue => e
  service.record(e)
  raise
ensure
  # ...
end