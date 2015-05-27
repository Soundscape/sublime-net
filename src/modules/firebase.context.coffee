Firebase = require 'firebase'
Err = require 'sublime-error'
Err.mixins.value()

# Wrapper around the Firebase API
class FirebaseContext
  # Construct a new FirebaseContext
  #
  # @param [String] url The URL to connect to
  constructor: (url) ->
    Err.Throw.isUnspecified url, 'Firebase URL'

    @ref = new Firebase url

  # Set the data at the specified path
  #
  # @param [String] path The partial path at which to store data
  # @param [Object] data The data to store
  set: (path, data) ->
    Err.Throw.isUnspecified path, 'path'
    Err.Throw.isUnspecified data, 'data'

    ref = @ref.child path
    ref.set data

  # Push data to the specified path
  #
  # @param [String] path The partial path at which to store data
  # @param [Object] data The data to store
  push: (path, data) ->
    Err.Throw.isUnspecified path, 'path'
    Err.Throw.isUnspecified data, 'data'

    ref = @ref.child path
    ref.push data

  # Remove the data at the specified path
  #
  # @param [String] path The partial path at which to remove data
  remove: (path) ->
    Err.Throw.isUnspecified path, 'path'

    ref = @ref.child path
    ref.remove()

  # Update the data at the specified path
  #
  # @param [String] path The partial path at which to store data
  # @param [Object] data The data to store
  update: (path, data) ->
    Err.Throw.isUnspecified path, 'path'
    Err.Throw.isUnspecified data, 'data'

    ref = @ref.child path
    ref.update data

  # Query the data at the specified path
  #
  # @param [String] path The partial path at which to store data
  # @param [Object] q The query parameters
  query: (path, q) ->
    Err.Throw.isUnspecified path, 'path'

    ref = @ref.child path

    if q and q.limit and q.limit > 0
      ref = ref.limit q.limit

    if q and q.order
      ref = ref.orderByChild q.order

    ref

module.exports = FirebaseContext
