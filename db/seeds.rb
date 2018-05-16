# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user1 = User.create(first_name: 'Awesome', last_name: 'user1', email: 'user1@gmail.com', password: '666666')
user2 = User.create(first_name: 'Awesom', last_name: 'user2', email: 'user2@gmail.com', password: '666666')

todo_list1 = TodoList.create(name: 'User1\'s List')
todo_list1.todo_listships.create(user: user1, role: :owner)

todo1 = Todo.create description: 'todo1', complete: false, todo_list: todo_list1
todo2 = Todo.create description: 'todo2', complete: false, todo_list: todo_list1

EventLogger.log(resource: todo1, user: user1, action: :create, tag: todo_list1.log_tag)
EventLogger.log(resource: todo2, user: user1, action: :create, tag: todo_list1.log_tag)

todo2.complete = true
todo2.save
EventLogger.log(resource: todo2, user: user1, action: :update, tag: todo_list1.log_tag, changes: todo2.previous_changes.except(:updated_at))
