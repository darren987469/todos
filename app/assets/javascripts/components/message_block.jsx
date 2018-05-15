MessageBlock = (props) => {
  const { message, onDismiss } = props
  const { content, type } = message
  return(
    <div className={ `alert alert-block ${ type === 'error' ? 'alert-danger' : 'alert-info'}` }>
      <a className="close" onClick={onDismiss}>
        <i className="ace-icon fa fa-times"></i>
      </a>
      { content }
    </div>
  )
}

MessageBlock.propTypes = {
  message: PropTypes.shape({
    type: PropTypes.string.isRequired,
    content: PropTypes.oneOfType([
     PropTypes.element.isRequired,
     PropTypes.string.isRequired,
    ]),
  }),
  onDismiss: PropTypes.func.isRequired,
}
