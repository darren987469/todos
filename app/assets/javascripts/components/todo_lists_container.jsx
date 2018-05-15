class TodoListsContainer extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      todoLists: props.todoLists,
      currentTodoList: props.currentTodoList,
      todos: props.todos,
      logs: props.logs,
      message: null,
    }
    this.connected = this.connected.bind(this)
    this.disconnected = this.disconnected.bind(this)
    this.rejected = this.rejected.bind(this)
    this.received = this.received.bind(this)
    this.redirect = this.received.bind(this)
    this.nextLogsState = this.nextLogsState.bind(this)
    this.toTop = this.toTop.bind(this)
    this.showError = this.showError.bind(this)
    this.showMessage = this.showMessage.bind(this)

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

  componentWillUnmount(){
    this.subscription.unsubscribe()
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
    const { currentUser } = this.props
    if(data.errors){
      this.showError(data.errors.join(', '))
      return
    }
    switch(data.action){
      case 'create_todo_list':
        window.location = `/todo_lists/${data.todo_list.id}`
        return
      case 'update_todo_list':
        this.showError(
          <div>
            The page is outdated.
            <a onClick={() => window.location.reload()} style={{ cursor: 'pointer' }}>
              Reload.
            </a>
          </div>
        )
        return
      case 'destroy_todo_list':
        this.showError(
          <div>
            The list is deleted.
            <a href="/todo_lists" style={{ cursor: 'pointer' }}>
              Refresh.
            </a>
          </div>
        )
        return
      case 'delete_member':
        if(data.member.id === currentUser.id){
          this.showError(
            <div>
              You are disable to access this List.
              <a href="/todo_lists" style={{ cursor: 'pointer' }}>
                Refresh.
              </a>
            </div>
          )
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

  showError(content){
    this.setState({ message: { type: 'error', content: content } })
    this.toTop()
  }

  showMessage(content){
    this.setState({ message: { type: 'info', content: content } })
    this.toTop()
  }

  toTop(){
    document.body.scrollTop = 0; // For Safari
    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
  }

  nextLogsState(newLog){
    return this.state.logs.concat(newLog).sort((a, b) => b.id - a.id)
  }

  createTodoListRequest(){
    this.request('create_todo_list')
  }

  createTodoRequest(description){
    this.request('create_todo', { todo: { description: description }})
  }

  patchTodoRequest(id, params, callback){
    this.request('update_todo', { todo: Object.assign({ id: id }, params) })
  }

  destroyTodoRequest(id){
    this.request('destroy_todo', { todo: { id: id } })
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
  }

  render() {
    const { currentTodoList, todoLists, todos, logs, message } = this.state
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
                    <i className="ace-icon fa fa-angle-double-right" style={{ marginRight: '5px' }}/>
                    <a href={`/todo_lists/${currentTodoList.id}/edit`}>
                      <i className="fa fa-cog"/>
                      Settings
                    </a>
                  </small>
                </h1>
              </div>

              <div className="row" style={{ height: '500px'}}>

                {/* Message Block */}
                { message && <MessageBlock message={ message } onDismiss={() => this.setState({ message: null })}/> }

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
                          required="true"
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

  componentWillUnmount(){
    clearInterval(this.timerId)
    this.timerId = null
  }

  tick(){
    if(this.timerId)
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
