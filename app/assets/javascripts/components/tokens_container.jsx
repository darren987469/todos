class TokensContainer extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      tokens: props.tokens,
      message: null
    }
    this.request = this.request.bind(this)
    this.createTokenRequest = this.createTokenRequest.bind(this)
    this.deleteTokenRequest = this.deleteTokenRequest.bind(this)
  }

  newTokenMessage() {
    return({
      type: 'info',
      content: 'Make sure to copy your new personal access token now. You won’t be able to see it again!'
    })
  }

  createTokenRequest(params) {
    this.request(params, {
      url: '/api/v1/tokens',
      method: 'POST',
      success: (res) => {
        this.setState(prevState => {
          return({
            tokens: prevState.tokens.concat(res),
            message: this.newTokenMessage()
          })
        })
      }
    })
  }

  deleteTokenRequest(tokenId) {
    this.request({}, {
      url: `/api/v1/tokens/${tokenId}`,
      method: 'DELETE',
      success: (res) => {
        this.setState(prevState => {
          return({ tokens: prevState.tokens.filter(token => token.id != res.id) })
        })
      }
    })
  }

  request(params = {}, options = {}) {
    let defaultOptions = {
      method: 'GET',
      contentType: 'application/json',
      data: JSON.stringify(params)
    }
    $.ajax({ ...defaultOptions, ...options })
  }

  render() {
    const { createTokenRequest, deleteTokenRequest } = this
    const { tokens, message } = this.state
    return(
      <div className="main-container">
        <div className="main-content">
          <div className="main-content-inner">
            <div className="page-content">
              <div className="page-header">
                <h1>
                  <strong> Personal access tokens </strong>
                  <strong style={{ fontSize: '18px' }}>
                    <i className="ace-icon fa fa-angle-double-right" style={{ margin: '0px 5px' }}/>
                    <a href={'/todo_lists'}>Back to TodoList</a>
                  </strong>
                </h1>
              </div>
              <div>Tokens you have generated that can be used to access the <a href="/swagger">Todo API</a></div>
              <div className="row">
                <div className="col-sm-8">
                  <TokenList
                    tokens={ tokens }
                    deleteTokenRequest={ deleteTokenRequest } />
                  { message && <MessageBlock message={ message } onDismiss={() => this.setState({ message: null })}/> }
                  <div className="space-8"/>
                  <TokenForm createTokenRequest={ createTokenRequest }/>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    )
  }
}
