class TodoListsContainer extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      todoLists: props.todo_lists,
      currentTodoList: props.current_todo_list,
      todos: props.todos,
      logs: props.logs,
      error: null
    }
    this.connected = this.connected.bind(this)
    this.disconnected = this.disconnected.bind(this)
    this.rejected = this.rejected.bind(this)
    this.received = this.received.bind(this)
    this.redirect = this.received.bind(this)
    this.nextLogsState = this.nextLogsState.bind(this)

    this.addMemberRequest = this.addMemberRequest.bind(this)
    this.createTodoRequest = this.createTodoRequest.bind(this)
    this.patchTodoRequest = this.patchTodoRequest.bind(this)
    this.destroyTodoRequest = this.destroyTodoRequest.bind(this)
    this.request = this.request.bind(this)
  }

  componentDidMount(){
    console.log('componentDidMount')
    this.subscription = App.cable.subscriptions.create({
      channel: 'TodoListChannel', id: this.state.currentTodoList.id
    },
    {
      connected: this.connected,
      disconnected: this.disconnected,
      rejected: this.rejected,
      received: this.received,
    })
  }

  connected(){
    console.log('connected')
  }

  disconnected(){
    console.log('disconnected')
  }

  rejected(){
    console.log('rejected')
  }

  received(data){
    console.log('received data', data)
    if(data.errors){
      this.setState({ error: data.errors.join(', ') })
      this.toTop()
      return
    }
    switch(data.action){
      case 'create_todo_list':
        window.location = `/todo_lists/${data.todo_list.id}`
        return
      case 'destroy_todo_list':
        window.location = '/todo_lists'
        return
      case 'add_member':
        alert(`Successful add member ${data.member.first_name} ${data.member.last_name}!`)
        this.addMemberEmailInput.value = ''
        if(data.log){
          this.setState({ logs: this.nextLogsState(data.log) })
        }
        return
    }
    this.setState(prevState => {
      var nextTodos
      switch(data.action){
        case 'create_todo':
          nextTodos = prevState.todos.concat(data.todo)
          this.newTodoDescriptionInput.value = ''
          break
        case 'update_todo':
          if(data.todo.archived_at) // filter archived
            nextTodos = prevState.todos.filter(todo => todo.id !== data.todo.id)
          else
            nextTodos = prevState.todos.map(todo => todo.id === data.todo.id ? data.todo : todo)
          break
        case 'destroy_todo':
          nextTodos = prevState.todos.filter(todo => todo.id !== data.todo.id)
          break
        default:
          console.error('unknown action')
          return
      }
      nextTodos.sort((a, b) => a.id - b.id)

      var nextLogs = prevState.logs
      if(data.log){
        nextLogs = this.nextLogsState(data.log)
      }

      return({ todos: nextTodos, logs: nextLogs })
    })
  }

  toTop(){
    document.body.scrollTop = 0; // For Safari
    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
  }

  nextLogsState(newLog){
    return this.state.logs.concat(newLog).sort((a, b) => b.id - a.id)
  }

  addMemberRequest(email){
    this.request('add_member', { id: this.state.currentTodoListId, email: email })
  }

  createTodoListRequest(){
    this.request('create_todo_list')
  }

  destroyTodoListRequest(id){
    this.request('destroy_todo_list', { id: id })
  }

  createTodoRequest(description){
    this.request('create_todo', { todo: { description: description }})
    /*
      this.request(
        { todo: { description: description }},
        {
          url: `/todo_lists/${this.props.todo_list_id}/todos`,
          method: 'POST',
          success: (res) => {
            this.setState(prevState => {
              return({ todos: prevState.todos.concat(res) })
            })
          }
        }
      )
    */
  }

  patchTodoRequest(id, params, callback){
    this.request('update_todo', { todo: Object.assign({ id: id }, params) })
    /*
      this.request(
        { todo: params },
        {
          url: `/todo_lists/${this.props.todo_list_id}/todos/${id}`,
          method: 'PATCH',
          success: (res, textStatus, xhr) => {
            if(xhr.status == 200){
              this.setState(prevState => {
                return({
                  todos: prevState.todos.map(todo =>
                    todo.id === res.id ? res : todo
                  )
                })
              })
            }
            if(callback)
              callback(res, textStatus, xhr)
          }
        }
      )
    */
  }

  destroyTodoRequest(id){
    this.request('destroy_todo', { todo: { id: id } })
    /*
      this.request(
        {},
        {
          url: `/todo_lists/${this.props.todo_list_id}/todos/${id}`,
          method: 'DELETE',
          success: (res, textStatus, xhr) => {
            if(xhr.status == 200){
              this.setState(prevState => {
                return({ todos: prevState.todos.filter(todo => todo.id !== res.id) })
              })
            }
          }
        }
      )
    */
  }

  request(method, params = {}, options = {}){
    console.log('request method:', method)
    const data = Object.assign(
      { method: method },
      { todo_list_id: this.state.currentTodoList.id },
      params
    )
    console.log('request data:', data)
    this.subscription.perform('request', data)
    /*
      var defaultOptions = {
        method: 'GET',
        contentType: 'application/json',
        data: JSON.stringify(params),
      }
      $.ajax({ ...defaultOptions, ...options })
    */
  }

  render() {
    const { currentTodoList, todoLists, todos, logs, error } = this.state
    const { createTodoRequest, patchTodoRequest, destroyTodoRequest } = this
    return(
      <div className="main-container">
        <div className="sidebar">
          <ul className="nav nav-list">
            {
              todoLists.map(todoList =>
                <li key={todoList.id} className={ todoList.id === currentTodoList.id ? 'active' : ''}>
                  <a href={`/todo_lists/${todoList.id}`}>
                    <span className="menu-text">{ todoList.name }</span>
                  </a>
                </li>
              )
            }
            <li>
              <a
                onClick={() => this.createTodoListRequest() }
                style={{ cursor: 'pointer' }}
              >
                <span className="menu-text">Add List</span>
                <b className="arrow fa fa-plus blue"/>
              </a>
            </li>
          </ul>

        </div>
        <div className="main-content">
          <div className="main-content-inner">
            <div className="page-content">
              <div className="page-header">
                <h1>
                  { currentTodoList.name }
                  <small>
                    <i className="ace-icon fa fa-angle-double-right"/>
                    <a href={`/todo_lists/${currentTodoList.id}/edit`}> Settings </a>
                  </small>
                </h1>
              </div>

              <div className="row" style={{ height: '500px'}}>

                {/* Error Message Block */}
                {
                  error &&
                  <div className="alert alert-block alert-danger">
                    <a className="close" onClick={() => this.setState({ error: null })}>
                      <i className="ace-icon fa fa-times"></i>
                    </a>
                    { error }
                  </div>
                }
                {/* Error Message */}

                <div className="col-sm-6">
                  <div className="dd">
                    <form onSubmit={event => {
                      event.preventDefault()
                      this.createTodoRequest(this.newTodoDescriptionInput.value)
                    }}>
                      <div className="input-group">
                        <input type="text"
                          ref={el => this.newTodoDescriptionInput = el}
                          className="form-control"
                          placeholder="Add Todo..."
                        />
                        <span className="input-group-btn">
                          <button className="btn btn-primary btn-sm">Add Todo</button>
                        </span>
                      </div>
                    </form>
                    <div className="space-8"/>
                    <ol className="dd-list">
                      {
                        todos.map(todo =>
                          <Todo
                            key={ todo.id }
                            todo={ todo }
                            patchTodoRequest={ patchTodoRequest }
                            destroyTodoRequest={ destroyTodoRequest }
                          />
                        )
                      }
                    </ol>
                  </div>
                </div>

                <div className="col-sm-6">
                  <div className="widget-box transparent">
                    <div className="widget-header widget-header-small">
                      <h4 className="widget-title blue smaller">
                        <i className="ace-icon fa fa-rss orange"/>
                        Recent Activities
                      </h4>
                    </div>
                    <div className="widget-body">
                      <div className="widget-main padding-8" style={{ maxHeight: '500px', overflowY: 'auto' }}>
                        { logs.map(log => <Log key={log.id} log={log}/>) }
                      </div>
                    </div>
                    <p>Note: Hold a while on Detail to see tooltip.</p>
                  </div>
                </div>
              </div>

              <div className="row">
                <div className="col-sm-6">
                  <div className="widget-box widget-color-blue">
                    <div className="widget-header">
                      <h4>Add member</h4>
                    </div>
                    <div className="widget-body">
                      <div className="widget-main">
                        <form onSubmit={e => {
                          e.preventDefault()
                          const email = this.addMemberEmailInput.value
                          this.addMemberRequest(email)
                        }}>
                          Add a member to the todo list.
                          <div className="input-group">
                            <input type="email"
                              ref={el => this.addMemberEmailInput = el}
                              className="form-control"
                              placeholder="Add member email..."
                            />
                            <span className="input-group-btn">
                              <button className="btn btn-primary btn-sm">Add Member</button>
                            </span>
                          </div>
                        </form>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="col-sm-6">
                  <div className="widget-box widget-color-red2">
                    <div className="widget-header">
                      <h4>Danger Zone</h4>
                    </div>
                    <div className="widget-body">
                      <div className="widget-main">
                        <button
                          className="btn btn-danger btn-sm"
                          onClick={() => this.destroyTodoListRequest(currentTodoList.id)}
                        >
                          Delete this todo list
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}

TodoListsContainer.propTypes = {
  todo_list_id: PropTypes.number,
  todos: PropTypes.array.isRequired,
  logs: PropTypes.array.isRequired
}

class Todo extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      mode: 'show', // or 'edit'
      description: props.todo.description,
      descriptionWas: props.todo.description,
    }
    this.handleUpdate = this.handleUpdate.bind(this)
    this.handleArchive = this.handleArchive.bind(this)
    this.renderShow = this.renderShow.bind(this)
    this.renderEdit = this.renderEdit.bind(this)
  }

  handleUpdate(){
    const { todo, patchTodoRequest } = this.props
    patchTodoRequest(
      todo.id,
      { description: this.state.description },
      /* for ajax callback
        (res, textStatus, xhr) => {
          if(xhr.status == 200)
            this.setState({ mode: 'show' })
        }
      */
    )
    // for websocket callback
    this.setState({ mode: 'show' })
  }

  handleArchive(){
    const { todo, patchTodoRequest } = this.props
    patchTodoRequest(todo.id, { archived_at: new Date() })
  }

  renderShow(){
    const { todo, patchTodoRequest, destroyTodoRequest } = this.props
    return(
      <li className="dd-item">
        <div className="dd-handle">
          <label style={{ marginRight: '5px' }}>
            <input
              name="complete"
              type="checkbox"
              className="ace"
              checked={ todo.complete }
              onChange={ () => {
                patchTodoRequest(todo.id, { complete: !todo.complete })
              }}
            />
            <span className="lbl"></span>
          </label>
          { todo.complete ? <s>{ todo.description }</s> : todo.description }
          <div className="pull-right action-buttons">
            {
              !todo.complete &&
              <a className="blue" onClick={() => this.setState({ mode: 'edit' })} title="edit">
                <i className="ace-icon fa fa-pencil bigger-150"></i>
              </a>
            }
            {
              todo.complete &&
              <a className="brown" onClick={this.handleArchive} title="archive">
                <i className="ace-icon fa fa-archive bigger-150"></i>
              </a>
            }
            <a className="red" onClick={() => destroyTodoRequest(todo.id)} title="delete">
              <i className="ace-icon fa fa-trash-o bigger-150"></i>
            </a>
          </div>
        </div>
      </li>
    )
  }

  renderEdit(){
    const { todo, patchTodoRequest, destroyTodoRequest } = this.props
    return(
      <li className="dd-item">
        <div className="dd-handle">
          <label style={{ marginRight: '5px' }}>
            <input
              name="complete"
              type="checkbox"
              className="ace"
              checked={ todo.complete }
              onChange={ e => {
                patchTodoRequest(todo.id, { complete: e.target.value })
              }}
            />
            <span className="lbl"></span>
          </label>
          <input
            type="text"
            className="input-xlarge"
            value={this.state.description}
            onChange={event => this.setState({ description: event.target.value })}
          />
          <div className="pull-right action-buttons">
            <a className="green" onClick={this.handleUpdate}>
              <i className="ace-icon fa fa-check bigger-150"></i>
            </a>
            <a className="red" onClick={() => this.setState({ mode: 'show' })}>
              <i className="ace-icon fa fa-times bigger-150"></i>
            </a>
          </div>
        </div>
      </li>
    )
  }

  render(){
    return(
      this.state.mode === 'show' ? this.renderShow() : this.renderEdit()
    )
  }
}

class Log extends React.Component{
  constructor(props){
    super(props)
    this.state = {
      created_at: this.formatCreatedAt(),
    }
  }

  componentDidMount(){
    this.timerId = setInterval(() => this.tick(), 1000)
  }

  componentWillMount(){
    clearInterval(this.timerId)
  }

  tick(){
    this.setState({ created_at: this.formatCreatedAt() })
  }

  formatCreatedAt(){
    return(moment(this.props.log.created_at).fromNow())
  }

  renderDetail(log) {
    const changes = log.variation
    return `id: ${log.resourceable_id}` + (changes ?
      ', ' + Object.keys(changes).map(attribute => `${attribute}: ${changes[attribute][0]} => ${changes[attribute][1]}`).join(', ') : '')
  }

  render(){
    const { log } = this.props
    const { showDetail } = this.state
    return(
      <div className="profile-activity clearfix">
        <div>
          { log.description }
          <a>
            {
              log.variation ?
              <span title={this.renderDetail(log)}> Detail </span> : ''
            }
            {/* <b className="arrow fa fa-angle-down"></b> */}
          </a>

          <div className="time">
            <i className="ace-icon fa fa-clock-o bigger-110" style={{ marginRight: '5px' }}/>
            { this.state.created_at }
          </div>
        </div>
      </div>
    )
  }
}
