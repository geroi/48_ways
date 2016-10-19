# Item 1
All is true except false and nil

# Item 2
any_object.nil?
nil.to_s
.to_a
.to_i
Array.compact #kills all nil

# Item 3
Prefer str.match to =~

# Item 4
CONSTANTS.freeze #beacuse consant are mutable

# Item 5
ruby -w #enable warnings

# Item 6
No Module.new
singleton_class
singleton_methods
В поиске етода идет вверх по иерархии
Если не находит, ищет method_missing, потом Kernel.method_missing
Когда делаем include ModuleName - ModuleName превращается в singleton (анонимный и невидимый) суперкласс и встает
между классом и суперклассом
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
super #вызывает аналогичный метод суперкласса