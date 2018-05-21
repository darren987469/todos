class NavBar extends React.Component {
  render(){
    const { currentUser, notifications } = this.props
    return(
      <div className="navbar-buttons navbar-header pull-right">
        <ul className="nav ace-nav">
          <NotificationBell notifications={notifications} />
          <li className="light-blue">
            <a className="dropdown-toggle">
              <i className="ace-icon fa fa-users"></i>
              <span className="user-info">
                <small>Welcome,</small>
                { `${currentUser.first_name} ${currentUser.last_name}` }
              </span>
            </a>
          </li>
          <li className="light-blue">
            <a rel="nofollow" data-method="delete" href="/users/sign_out">Logout</a>
          </li>
        </ul>
      </div>
    )
  }
}

NavBar.propTypes = {
  currentUser: PropTypes.object.isRequired,
}
