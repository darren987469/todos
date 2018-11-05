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

TokenList.propTypes = {
  deleteTokenRequest: PropTypes.func.isRequired,
  tokens: PropTypes.array
}
