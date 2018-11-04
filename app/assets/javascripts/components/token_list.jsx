function TokenList(props) {
  const { tokens } = props
  return(
    <ol className="dd-list">
      <li className="dd-item">
        {
          tokens.map(token =>
            <TokenItem
              key={ token.id }
              token={ token }
              deleteTokenRequest={ props.deleteTokenRequest } />
          )
        }
      </li>
    </ol>
  )
}

function TokenItem(props) {
  const { token } = props
  return(
    <div className="dd-handle">
      <a href="">{ token.note }</a> - { token.scopes.join(', ') }
      <div className="pull-right action-buttons">
        <a className="red" onClick={ ()=>{ props.deleteTokenRequest(token.id) } }>
          <i className="ace-icon fa fa-trash-o bigger-130"></i>
        </a>
      </div>
    </div>
  )
}
