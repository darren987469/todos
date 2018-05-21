class NotificationBell extends React.Component {
  constructor(props){
    super(props)
    this.state = {
      notifications: props.notifications,
      show: false
    }
    this.onBellClick = this.onBellClick.bind(this)
  }

  onBellClick(){
    const { notifications } = this.props
    this.setState({ show: !this.state.show })
  }

  renderNoNotification(){

  }

  render() {
    const { notifications, show } = this.state
    return(
      <li className={ `purple dropdown-modal ${show ? 'open' : ''}` }>
        <a data-toggle="dropdown" className="dropdown-toggle" onClick={this.onBellClick} style={{ cursor: 'pointer' }}>
          <i className="ace-icon fa fa-bell"></i>
          {
            notifications.length > 0 &&
            <span className="badge badge-important">{ notifications.length }</span>
          }
        </a>

        <ul className="dropdown-menu-right dropdown-navbar dropdown-menu dropdown-caret dropdown-close">
          <li className="dropdown-header">
            <i className="ace-icon fa fa-exclamation-triangle"></i>
            { notifications.length } Notifications
          </li>

          <li className="dropdown-content" style={{ position: 'relative' }}>
            <ul className="dropdown-menu dropdown-navbar navbar-pink">
              { notifications.map(notification => <NotificationItem notification={notification} />) }
            </ul>
          </li>

          <li className="dropdown-footer">
            <a>
              See all notifications
              <i className="ace-icon fa fa-arrow-right"></i>
            </a>
          </li>
        </ul>
      </li>
    )
  }
}

Notification.propTypes = {
  notifications: PropTypes.array.isRequired,
}

const NotificationItem = (props) => {
  const { notification } = props
  return(
    <li>
      <a>
        { notification.description }
      </a>
    </li>
  )
}
