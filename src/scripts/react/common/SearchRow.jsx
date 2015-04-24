import React from 'react';


export default  React.createClass({

  propTypes: {
    query: React.PropTypes.string.isRequired,
    onChange: React.PropTypes.func,
    onSubmit: React.PropTypes.func,
    className: React.PropTypes.string,
  },

  getInitialState() {
    return {
      query: this.props.query
    };
  },

  getDefaultProps() {
    return {
      onChange: () => {},
      onSubmit: (e) => e.preventDefault()
    }
  },

  componentDidMount() {
    this.refs.searchInput.getDOMNode().focus();
  },

  _onChange(event) {
    this.setState({
      query: event.target.value
    });
    this.props.onChange(event.target.value);
  },

  _onSubmit(event) {
    event.preventDefault();
    this.props.onSubmit(this.state.query);
  },

  render() {
    return (
      <form className={"kbc-search " + this.props.className} onSubmit={this._onSubmit}>
        <span className="kbc-icon-search"></span>
        <input
          type="text"
          value={this.state.query}
          className="form-control"
          placeholder="Search"
          ref="searchInput"
          onChange={this._onChange}
        />
      </form>
    );
  }

});