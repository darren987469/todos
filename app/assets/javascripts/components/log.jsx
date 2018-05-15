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
