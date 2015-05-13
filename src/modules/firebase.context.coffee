Firebase = require 'firebase'

validate = (val, fn, msg) ->
  if fn(val)
    console.error msg
    throw new Error msg

isNull = (val, name) ->
  fn = (v) -> !v
  validate val, fn, "*#{name}* may not be NULL"

class FirebaseContext
  constructor: (url) ->
    @ref = new Firebase url

  set: (path, data) ->
    isNull path, 'path'
    isNull data, 'data'

    ref = @ref.child path
    ref.set data

  push: (path, data) ->
    isNull path, 'path'
    isNull data, 'data'

    ref = @ref.child path
    ref.push data

  remove: (path) ->
    isNull path, 'path'

    ref = @ref.child path
    ref.remove()

  update: (path, data) ->
    isNull path, 'path'
    isNull data, 'data'

    ref = @ref.child path
    ref.update data

  query: (path, q) ->
    isNull path, 'path'

    ref = @ref.child path

    if q and q.limit and q.limit > 0
      ref = ref.limit q.limit

    if q and q.order
      ref = ref.orderByChild q.order

    ref

module.exports = FirebaseContext
