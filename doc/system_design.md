# System design

This app connects users by actioncable(websocket). One user's action will appear on another user's browser. Users can share todo list with each other and see changes without reload page. Every user action is logged and displayed to users.

## DB Design

Please take a look at [DB Schema](Todos_DB_Schema.png)

## Websocket mechanism

TodoListChannel contains the socket logic. It handles and broadcasts the following envets:

* create_todo
* update_todo
* destroy_todo
* create_todo_list

Other events handled and broadcast in TodoListsController and TodoListshipsController

* update_todo_list
* destroy_todo_list
* add_member
* delete_member

Current use `todo_list_[:id]` as token to let subscriber subscribe. The socket server will broad events according to the token. Client and server use these events to communication.

## Logging mechanism

Model `EventLog` is used to record user actions. EventLog has these attributes: resourceable_id, resourceable_type, user_id, log_tag, action, description. `log_tag` column is used to record the log belongs to which todo list. So we can find logs related to a todo list easily.
