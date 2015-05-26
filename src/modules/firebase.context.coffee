Firebase = require 'firebase'

validate = (val, fn, msg) ->
  if fn(val)
    console.error msg
    throw new Error msg

isNull = (val, name) ->
  fn = (v) -> !v
  validate val, fn, "*#{name}* may not be NULL"

# Wrapper around the Firebase API
class FirebaseContext
  # Construct a new FirebaseContext
  #
  # @param [String] url The URL to connect to
  constructor: (url) ->
    @ref = new Firebase url

  # Set the data at the specified path
  #
  # @param [String] path The partial path at which to store data
  # @param [Object] data The data to store
  set: (path, data) ->
    isNull path, 'path'
    isNull data, 'data'

    ref = @ref.child path
    ref.set data

  # Push data to the specified path
  #
  # @param [String] path The partial path at which to store data
  # @param [Object] data The data to store
  push: (path, data) ->
    isNull path, 'path'
    isNull data, 'data'

    ref = @ref.child path
    ref.push data

  # Remove the data at the specified path
  #
  # @param [String] path The partial path at which to remove data
  remove: (path) ->
    isNull path, 'path'

    ref = @ref.child path
    ref.remove()

  # Update the data at the specified path
  #
  # @param [String] path The partial path at which to store data
  # @param [Object] data The data to store
  update: (path, data) ->
    isNull path, 'path'
    isNull data, 'data'

    ref = @ref.child path
    ref.update data

  # Query the data at the specified path
  #
  # @param [String] path The partial path at which to store data
  # @param [Object] q The query parameters
  query: (path, q) ->
    isNull path, 'path'

    ref = @ref.child path

    if q and q.limit and q.limit > 0
      ref = ref.limit q.limit

    if q and q.order
      ref = ref.orderByChild q.order

    ref

module.exports = FirebaseContext
