# System spec

## Use cases

* User signs in/out
* User views/creates/edits/deletes/invites member to TodoList
* User creates/edits/deletes/archives Todo
* User views EventLog
* User views/creates/deletes access token
* Application developer accesses resource through API

## Constraints and assumptions

* Traffic is not evenly distributed
* Every update for todo should apply to users without refreshing page
* 1 million active users
* 10 million new todos per day
* 50 million read requests per day

Calculate usage

* Size per todo
  * `todo_id` - 8 bytes
  * `user_id` - 8 bytes
  * `todo_list_id` - 8 bytes
  * `description`  ~ 30 bytes
  * `complete` - 1 byte
  * `archived_at` - 8 bytes
  * `created_at` - 8 bytes
  * `updated_at` - 8 bytes
  * Assume ~ 100 bytes ~ 0.1 KB
* 10 million todo/day * 0.1 KB ~ 1 GB per day
  * 30 GB per month
  * 365 GB per year
* 58 read requests per second
* 12 new todo requests per second

## High-level design

![](images/high_level_design.png)
https://www.draw.io/#G1KF_OIeRQkhsfWZajTnZKSdSzXj5QHsyt

Some information should notify user immediately, such as CRUD of `Todo` and create/delete of `TodoList`. We use `Websocket Service` to handle those actions. Other actions are handled by `Read/Writer API`.

We use `Redis` to handle cache and high volume reads/writes. For example, API throttling data, which records API request rate per user, is stored in redis.

## Database schema

![](images/database_schema.png)
https://www.draw.io/#G1Wwmv8O3JBPwBJYDkv_3AvkWu05YHC4m2

`User` has many `TodoList` through `TodoListship`. There are three roles: owner, admin, and user. Each role has different permissions:

Role | user | admin | owner
-------------- | ------|-------|-----
read TodoList  | ️️V | V | V
create TodoList| V | V | V
update TodoList| X | V | V
invite member to TodoList| X | V | V
delete TodoList| X | X | V

`EventLog` is used to record every action of a user. Such as user creates `TodoList`, user updates `Todo` or user invites a member to `TodoList`.

`Token` records scopes the user authorized to application developer. Scopes format is `[action]:[resource]`, such as `read:log`, `write:log`.

## Potential bottleneck and TODOs

The bottleneck of this app maybe rails action cable. It has poor performance when handle a large number of client.

* Use Background job to reduce response time in controller caused by action cable broadcast.
* Separate websocket server and application server instead of just using one server. Avoid app server from being affected by slow websocket.
* If allowed, rewrite websocket server in another language such as Go, Erlang is better choice. Ruby on Rails is not fit for scalable concurrent applications. There is a open source project [AnyCable Rails](https://github.com/anycable/anycable-rails) do this.

References:
* [Action Cable 即時通訊](https://ihower.tw/rails/actioncable.html) by ihower
* [AnyCable: Action Cable on steroids](https://evilmartians.com/chronicles/anycable-actioncable-on-steroids) by Vladimir Dementyev

## API spec

See [API reference](doc/api_reference.md)
