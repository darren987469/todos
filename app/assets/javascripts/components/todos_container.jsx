class TodoListContainer extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      todos: props.todos,
      logs: props.logs,
    }
    this.connected = this.connected.bind(this)
    this.disconnected = this.disconnected.bind(this)
    this.rejected = this.rejected.bind(this)
    this.received = this.received.bind(this)

    this.createTodoRequest = this.createTodoRequest.bind(this)
    this.patchTodoRequest = this.patchTodoRequest.bind(this)
    this.deleteTodoRequest = this.deleteTodoRequest.bind(this)
    this.request = this.request.bind(this)
  }

  componentDidMount(){
    this.subscription = App.cable.subscriptions.create({
      channel: 'TodoListChannel', id: this.props.todo_list_id
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
    if(data.todo.errors){
      console.error(data.errors)
      return
    }
    this.setState(prevState => {
      var nextTodos
      switch(data.action){
        case 'create':
          nextTodos = prevState.todos.concat(data.todo)
          break
        case 'update':
          nextTodos = prevState.todos.map(todo => todo.id === data.todo.id ? data.todo : todo)
          break
        case 'destroy':
          nextTodos = prevState.todos.filter(todo => todo.id !== data.todo.id)
          break
        default:
          console.error('error')
          return
      }
      nextTodos.sort((a, b) => a.id - b.id)

      var nextLogs = prevState.logs
      if(data.log){
        nextLogs = nextLogs.concat(data.log)
      }

      return({ todos: nextTodos, logs: nextLogs })
    })
  }

  createTodoRequest(description){
    this.request('create', { todo: { description: description }})
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
    this.request('update', { todo: Object.assign({ id: id }, params) })
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

  deleteTodoRequest(id){
    this.request('destroy', { todo: { id: id } })
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

  request(method, params, options = {}){
    console.log('rdata:', Object.assign({ todo_list_id: this.props.todo_list_id }, params))
    this.subscription.perform(method, Object.assign({ todo_list_id: this.props.todo_list_id }, params))
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
    const { todos, logs } = this.state
    const { createTodoRequest, patchTodoRequest, deleteTodoRequest } = this
    return(
      <div className="page-content">
        <div className="row">
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
                      deleteTodoRequest={ deleteTodoRequest }
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
            </div>
          </div>
        </div>
      </div>
    )
  }
}

TodoListContainer.propTypes = {
  todo_list_id: PropTypes.number.isRequired,
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
    this.handleSubmit = this.handleSubmit.bind(this)
    this.renderShow = this.renderShow.bind(this)
    this.renderEdit = this.renderEdit.bind(this)
  }

  handleSubmit(event){
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

  renderShow(){
    const { todo, patchTodoRequest, deleteTodoRequest } = this.props
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
              <a className="blue" onClick={() => this.setState({ mode: 'edit' })}>
                <i className="ace-icon fa fa-pencil bigger-150"></i>
              </a>
            }
            <a className="red" onClick={() => deleteTodoRequest(todo.id)}>
              <i className="ace-icon fa fa-trash-o bigger-150"></i>
            </a>
          </div>
        </div>
      </li>
    )
  }

  renderEdit(){
    const { todo, patchTodoRequest, deleteTodoRequest } = this.props
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
            value={this.state.description}
            onChange={event => this.setState({ description: event.target.value })}
          />
          <div className="pull-right action-buttons">
            <a className="green" onClick={this.handleSubmit}>
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
    return `id: ${log.id}` + (changes ?
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
              <span title={this.renderDetail(log)}> Detail </span> :
              <span> Detail </span>
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
