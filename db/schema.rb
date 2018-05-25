# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_180_512_052_446) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'event_logs', force: :cascade do |t|
    t.string 'resourceable_type'
    t.bigint 'resourceable_id'
    t.bigint 'user_id'
    t.string 'log_tag'
    t.string 'action'
    t.string 'description'
    t.jsonb 'variation'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['log_tag'], name: 'index_event_logs_on_log_tag'
    t.index %w[resourceable_type resourceable_id], name: 'index_event_logs_on_resourceable_type_and_resourceable_id'
    t.index ['user_id'], name: 'index_event_logs_on_user_id'
  end

  create_table 'todo_lists', force: :cascade do |t|
    t.string 'name', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'todo_listships', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'todo_list_id', null: false
    t.integer 'role', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['todo_list_id'], name: 'index_todo_listships_on_todo_list_id'
    t.index %w[user_id todo_list_id], name: 'index_todo_listships_on_user_id_and_todo_list_id', unique: true
    t.index ['user_id'], name: 'index_todo_listships_on_user_id'
  end

  create_table 'todos', force: :cascade do |t|
    t.bigint 'todo_list_id'
    t.string 'description', null: false
    t.boolean 'complete', default: false
    t.datetime 'archived_at'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['complete'], name: 'index_todos_on_complete'
    t.index ['todo_list_id'], name: 'index_todos_on_todo_list_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'first_name', null: false
    t.string 'last_name', null: false
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.inet 'current_sign_in_ip'
    t.inet 'last_sign_in_ip'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  end
end
