# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user1 = User.create(first_name: 'Darren', last_name: 'Chang', email: 'darren.chang@gmail.com', password: '666666')
user2 = User.create(first_name: 'Darren', last_name: 'Handsome', email: 'darren.handsome@gmail.com', password: '666666')

todo_list1 = TodoList.create(name: 'Super Team')
todo_list1.todo_listships.create(user: user1, role: :owner)

Todo.create([
  { description: 'todo1', complete: false, todo_list: todo_list1 },
  { description: 'todo1', complete: true, todo_list: todo_list1 }
])