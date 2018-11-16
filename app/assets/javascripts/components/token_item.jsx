function TokenItem(props) {
  const { token } = props
  const description = token.encoded_token ? token.encoded_token : `${ token.note } - ${ token.scopes.join(', ') }`
  return(
    <div className="dd-handle" style={{ wordBreak: 'break-all' }}>
      { description }
      <div className="pull-right action-buttons">
        <a className="red" onClick={ ()=>{ props.deleteTokenRequest(token.id) } }>
          <i className="ace-icon fa fa-trash-o bigger-130"></i>
        </a>
      </div>
    </div>
  )
}

TokenItem.propTypes = {
  token: PropTypes.shape({
    id: PropTypes.number.isRequired,
    note: PropTypes.string.isRequired,
    scopes: PropTypes.arrayOf(PropTypes.string),
    encoded_token: PropTypes.string
  })
}
