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

Todo.propTypes = {
  todo: PropTypes.object.isRequired,
  patchTodoRequest: PropTypes.func.isRequired,
  destroyTodoRequest: PropTypes.func.isRequired,
}
