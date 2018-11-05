class TokenForm extends React.Component {
  constructor(props) {
    super(props)
    this.state = {
      note: '',
      scopes: []
    }
    this.handleInputChange = this.handleInputChange.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
  }

  handleInputChange(event) {
    const target = event.target;
    const name = target.name;
    const value = target.value
    switch(target.type){
      case 'checkbox':
        this.setState(prevState => {
          let scopes = prevState.scopes.slice()
          if(target.checked){
            return({ [name]: scopes.concat(value) })
          } else {
            return({ [name]: scopes.filter(scope => scope != value) })
          }
        })
        break
      case 'text':
        this.setState({ [name]: value })
    }
  }

  handleSubmit(event) {
    event.preventDefault()
    let params = {
      note: this.state.note,
      scopes: this.state.scopes
    }
    if(params.scopes.length == 0) {
      alert('You must select at least 1 scope')
      return
    }
    this.props.createTokenRequest(params)
  }

  render() {
    const { note, scopes } = this.state
    return(
      <form onSubmit={ this.handleSubmit }>
        <label>Token description (What's this token for?)</label>
        <br></br>
        <input
          name="note"
          type="text"
          value={ note }
          required="true"
          onChange={ this.handleInputChange } />
        <div className="space-4"/>

        <label>Select Scopes</label>
        <br></br>
        {
          ['read:log', 'write:log'].map(scope => {
            return(
              <div key={scope}>
                <label>
                  <input
                    type="checkbox"
                    name="scopes"
                    value={ scope }
                    checked={ scopes.indexOf(scope) > -1 }
                    onChange={ this.handleInputChange } />
                    &nbsp;&nbsp;{ scope }
                </label>
              </div>
            )
          })
        }
        <input type="submit" className="btn btn-success btn-mini" value="Generate Token"></input>
      </form>
    )
  }
}

TokenForm.propTypes = {
  createTokenRequest: PropTypes.func.isRequired
}
