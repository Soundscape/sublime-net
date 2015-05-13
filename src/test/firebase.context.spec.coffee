lib = require '../'

describe 'Firebase test suite', ()  ->
  create = () -> new lib.Firebase 'https://sublime-dev.firebaseio.com/'

  it 'should construct an instance', () ->
    instance = create()
    expect instance
      .not.toBeNull()
