App.todoListSubscription = App.cable.subscriptions.create(
  'TodoListChannel',
  {
  connected: () => {
    console.log('connected')
  },
  disconnected: () => {
    console.log('disconnected')
  },
  rejected: () => {
    console.log('rejected')
  },
  received: (data) => {
    console.log('received data', data)
  }
})